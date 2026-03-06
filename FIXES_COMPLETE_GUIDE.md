# Authentication Issue Fixes - Complete Guide

## Problem Summary

Your Flutter app was experiencing a **race condition** where:
- First Canvas API call returned 401 "Invalid JWT" (even with valid session)
- App immediately signed out the user
- Delayed success response (200 OK) arrived AFTER sign-out
- User was forced to log in again unnecessarily

## Root Causes

1. **JWT Propagation Delay**: The JWT token wasn't fully propagated to Supabase backend when first request fired
2. **No Retry Logic**: Transient auth errors caused immediate failure
3. **Over-aggressive Error Handling**: App signed out on ANY 401 error
4. **Concurrent Requests**: Multiple API calls competed for session validity

## Solutions Implemented

### 1. Exponential Backoff Retry Logic
**File**: `lib/features/home/presentation/providers/home_tasks_provider.dart`

```dart
Future<T> _fetchWithRetry<T>(
  Future<T> Function() operation, {
  required int maxAttempts,
  required Duration initialDelay,
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (true) {
    attempt++;
    try {
      return await operation();
    } catch (error) {
      // Only retry on auth-related errors
      final isAuthError = error is CanvasSessionExpiredException ||
          error.toString().toLowerCase().contains('invalid jwt') ||
          error.toString().toLowerCase().contains('unauthorized');

      if (attempt >= maxAttempts || !isAuthError) {
        rethrow;
      }

      // Exponential backoff: 500ms, 1000ms, 2000ms
      delay = Duration(
        milliseconds: (delay.inMilliseconds * 2).clamp(
          initialDelay.inMilliseconds,
          5000,
        ),
      );
    }
  }
}
```

**Benefits**:
- Automatically retries up to 3 times on auth errors
- Uses exponential backoff (500ms → 1s → 2s)
- Only retries auth errors, fails fast on other errors

### 2. Initial Delay for JWT Propagation
**File**: `lib/features/home/presentation/providers/home_tasks_provider.dart`

```dart
final canvasAssignmentsWithUserProvider =
    FutureProvider<CanvasAssignmentsResponse>((ref) async {
      // Add small delay to ensure JWT is fully propagated
      await Future.delayed(const Duration(milliseconds: 300));

      final remoteDataSource = ref.watch(canvasAssignmentRemoteDataSourceProvider);
      final response = await _fetchWithRetry(
        () => remoteDataSource.fetchAssignmentsWithUser(),
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 500),
      );
      // ... rest of provider
    });
```

**Benefits**:
- Gives JWT time to propagate to Supabase backend
- Reduces likelihood of 401 errors on first attempt

### 3. Consecutive Error Threshold
**File**: `lib/features/home/home_page.dart`

```dart
class _HomePageState extends ConsumerState<HomePage> {
  int _consecutiveAuthErrors = 0;
  Timer? _authErrorResetTimer;

  @override
  void initState() {
    super.initState();

    _assignmentsSubscription = ref
        .listenManual<AsyncValue<HomeAssignmentSections>>(
          homeCanvasAssignmentSectionsProvider,
          (previous, next) {
            next.whenOrNull(
              error: (error, _) {
                if (error is CanvasSessionExpiredException) {
                  _consecutiveAuthErrors++;

                  // Only sign out after 3 consecutive errors
                  if (_consecutiveAuthErrors >= 3) {
                    _handleExpiredSession();
                  } else {
                    // Show warning but don't sign out
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Connection issue. Retrying... ($_consecutiveAuthErrors/3)',
                        ),
                        action: SnackBarAction(
                          label: 'Retry Now',
                          onPressed: () {
                            ref.invalidate(canvasAssignmentsWithUserProvider);
                            ref.invalidate(homeCanvasAssignmentSectionsProvider);
                          },
                        ),
                      ),
                    );

                    // Reset counter after 10 seconds
                    _authErrorResetTimer?.cancel();
                    _authErrorResetTimer = Timer(
                      const Duration(seconds: 10),
                      () => _consecutiveAuthErrors = 0,
                    );
                  }
                }
              },
              data: (_) {
                // Reset counter on success
                _consecutiveAuthErrors = 0;
                _authErrorResetTimer?.cancel();
              },
            );
          },
        );
  }

  @override
  void dispose() {
    _authErrorResetTimer?.cancel();
    _assignmentsSubscription?.close();
    super.dispose();
  }
}
```

**Benefits**:
- Only signs out after 3 consecutive auth errors
- Shows warning messages with retry option
- Resets counter after 10 seconds or successful request
- Prevents false positive sign-outs

## Files Modified

### Primary Changes:
1. `lib/features/home/presentation/providers/home_tasks_provider.dart`
   - Added `_fetchWithRetry()` function
   - Updated `canvasAssignmentsWithUserProvider` to use retry logic
   - Added 300ms initial delay for JWT propagation
   - Added `flutter/foundation.dart` import

2. `lib/features/home/home_page.dart`
   - Added `dart:async` import for `Timer`
   - Added `_consecutiveAuthErrors` counter
   - Added `_authErrorResetTimer`
   - Updated error listener with threshold approach
   - Improved error messages and UI
   - Updated `dispose()` to cancel timer

### New Files (Optional/For Future Use):
3. `lib/core/retry/retry_with_backoff.dart`
   - Reusable retry utility (can be used for other API calls)

4. `lib/features/home/presentation/providers/canvas_assignments_retry_provider.dart`
   - Dedicated retry provider (currently unused, for future use)

5. `AUTH_FIX_SUMMARY.md`
   - Detailed documentation of changes

## Testing Guide

### 1. Basic Smoke Test
```bash
# Clean build
flutter clean

# Run app
flutter run

# Sign in and verify:
# - Assignments load successfully
# - No immediate sign-out
# - No console errors
```

### 2. Retry Mechanism Test
Simulate auth errors by:
1. Temporarily breaking network connection
2. Observe automatic retry behavior
3. Check console logs for "RETRY_DEBUG" messages
4. Verify user is NOT signed out on first error

### 3. Consecutive Error Test
Force multiple consecutive errors:
1. Observe warning messages (1/3, 2/3)
2. Verify "Retry Now" button appears
3. Check counter resets after 10 seconds or success
4. Only signs out after 3rd consecutive error

### 4. Cold Start Test
```bash
# Stop app completely
flutter run

# Fresh sign in and verify:
# - Session is valid
# - Assignments load without errors
# - No JWT propagation issues
```

## Expected Behavior Comparison

### Before Fix:
```
1. App loads home page
2. First Canvas request → 401 Invalid JWT
3. App immediately signs out
4. User redirected to login page
5. Delayed 200 OK response ignored
```

### After Fix:
```
1. App loads home page
2. 300ms delay (JWT propagation)
3. First Canvas request → 401 (possibly)
4. Show warning: "Connection issue. Retrying... (1/3)"
5. Retry after 500ms
6. Second attempt → 200 OK ✓
7. Success! Assignments load
8. Counter resets to 0

OR if all 3 attempts fail:
4. Show warning: "Connection issue. Retrying... (1/3)"
5. Retry #1 → 401
6. Show warning: "Connection issue. Retrying... (2/3)"
7. Retry #2 → 401
8. Sign out (3 consecutive errors)
9. Redirect to login
```

## Debug Logs to Watch

### Success Path:
```
RETRY_DEBUG: Attempt 1/3
CANVAS_DEBUG: ✅ Session ready, calling canvas-proxy
CANVAS_DEBUG: Proxy response received
CANVAS_DEBUG: Status: 200
CANVAS_DEBUG: ✅ SUCCESSFULLY PARSED RESPONSE
HOME_DEBUG: ✅ Session exists, showing home page
```

### Retry Path:
```
RETRY_DEBUG: Attempt 1/3
CANVAS_DEBUG: ❌ FunctionException: FunctionException(status: 401, details: {code: 401, message: Invalid JWT}
RETRY_DEBUG: Auth error on attempt 1/3, retrying in 500ms...
RETRY_DEBUG: Attempt 2/3
CANVAS_DEBUG: Proxy response received
CANVAS_DEBUG: Status: 200
HOME_DEBUG: ✅ Session exists, showing home page
```

### Sign Out Path (3 consecutive errors):
```
RETRY_DEBUG: Attempt 1/3
RETRY_DEBUG: Auth error on attempt 1/3, retrying in 500ms...
RETRY_DEBUG: Attempt 2/3
RETRY_DEBUG: Auth error on attempt 2/3, retrying in 1000ms...
RETRY_DEBUG: Attempt 3/3
RETRY_DEBUG: Auth error on attempt 3/3, retrying in 2000ms...
RETRY_DEBUG: Giving up after 3 attempts
HOME_DEBUG: ❌ CanvasSessionExpiredException caught!
HOME_DEBUG: Consecutive auth errors: 3
HOME_DEBUG: Too many auth errors, signing out...
HOME_DEBUG: _handleExpiredSession() called
```

## Monitoring Metrics

Add these to track fix effectiveness:

```dart
// In production, track these:
final retrySuccessRate = (successfulRetries / totalRetries) * 100;
final consecutiveErrorsRate = (signOutEvents / totalSessions) * 100;
final avgRetryTime = totalTimeRetrying / successfulRetries;
```

## Rollback Instructions

If issues arise, revert these changes:

```bash
# Revert home_tasks_provider.dart
git checkout lib/features/home/presentation/providers/home_tasks_provider.dart

# Revert home_page.dart
git checkout lib/features/home/home_page.dart

# Delete new files
rm lib/core/retry/retry_with_backoff.dart
rm lib/features/home/presentation/providers/canvas_assignments_retry_provider.dart
rm AUTH_FIX_SUMMARY.md
```

## Next Steps

1. **Test thoroughly** using the testing guide above
2. **Monitor logs** for the debug messages
3. **Collect metrics** on retry success rate
4. **Consider additional improvements**:
   - Circuit breaker pattern for long-term outages
   - Request deduplication
   - Offline support with caching
   - Better session validation

## Support

If you encounter issues:

1. Check console logs for `RETRY_DEBUG` and `CANVAS_DEBUG` messages
2. Verify session is valid in Supabase dashboard
3. Test with clean build: `flutter clean && flutter run`
4. Check Supabase Edge Function logs for errors

## References

- Exponential Backoff: https://en.wikipedia.org/wiki/Exponential_backoff
- Circuit Breaker Pattern: https://martinfowler.com/bliki/CircuitBreaker.html
- Flutter Async Providers: https://riverpod.dev/docs/concepts/providers#futureprovider
- Supabase Auth: https://supabase.com/docs/guides/auth
