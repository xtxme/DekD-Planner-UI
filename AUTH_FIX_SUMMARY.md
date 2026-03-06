# Fix for Canvas Authentication Issue - Summary

## Problem Analysis

### Root Cause
The app was experiencing a **race condition** where:

1. **Multiple concurrent API calls** were made when Home Page loaded:
   - `fetchAssignmentsWithUser()` → calls Canvas proxy
   - `subjectListProvider` → may trigger additional requests

2. **First request received 401 "Invalid JWT"** even though the Supabase session was valid
3. **App immediately signed out the user** (over-aggressive error handling)
4. **Delayed success response (200 OK)** arrived AFTER user was already on login page

### Why the 401 Error Occurred

The JWT token might not have been fully propagated to Supabase's backend when the first request was fired. This is a common timing issue with:

- Freshly authenticated sessions
- Cold starts
- Network latency

## Solution Implemented

### 1. Added Retry Logic with Exponential Backoff
**File**: `lib/features/home/presentation/providers/home_tasks_provider.dart`

Added a `_fetchWithRetry()` helper function that:
- Retries up to 3 times on auth-related errors
- Uses exponential backoff (500ms, 1000ms, 2000ms)
- Only retries on specific errors:
  - `CanvasSessionExpiredException`
  - "Invalid JWT" errors
  - "Unauthorized" errors
- Fails fast on non-auth errors

**Benefits**:
- Handles transient network issues automatically
- Reduces false positive auth failures
- Provides better UX with automatic retries

### 2. Added Initial Delay for JWT Propagation
**File**: `lib/features/home/presentation/providers/home_tasks_provider.dart`

Added a 300ms delay before making the first Canvas request:
```dart
await Future.delayed(const Duration(milliseconds: 300));
```

**Benefits**:
- Ensures JWT is fully propagated to Supabase backend
- Reduces likelihood of 401 errors on first attempt

### 3. Implemented Consecutive Error Threshold
**File**: `lib/features/home/home_page.dart`

Changed the auth error handling to:
- Track consecutive auth errors with a counter
- Only sign out after 3 consecutive auth errors
- Show warning message with retry option before sign-out
- Reset counter after 10 seconds or successful request
- Clear timers properly in `dispose()`

**Benefits**:
- Prevents false positive sign-outs
- Gives user opportunity to retry
- Automatically recovers from transient issues

### 4. Improved Error Messages
**File**: `lib/features/home/home_page.dart`

Error messages now show:
- Connection issue detected
- Retry progress (e.g., "Retrying... (1/3)")
- "Retry Now" button in snack bar

## Changes Summary

### Modified Files

1. **`lib/features/home/presentation/providers/home_tasks_provider.dart`**
   - Added `flutter/foundation.dart` import
   - Added `_fetchWithRetry()` helper function
   - Updated `canvasAssignmentsWithUserProvider` to use retry logic
   - Added 300ms initial delay

2. **`lib/features/home/home_page.dart`**
   - Added `dart:async` import for `Timer`
   - Added `_consecutiveAuthErrors` counter
   - Added `_authErrorResetTimer`
   - Updated error listener to use threshold approach
   - Improved error messages and UI

### New Files

3. **`lib/core/retry/retry_with_backoff.dart`**
   - Reusable retry utility
   - Exponential backoff implementation
   - Extension method for `CanvasAssignmentRemoteDataSource`
   - (Can be used for other API calls in the future)

4. **`lib/features/home/presentation/providers/canvas_assignments_retry_provider.dart`**
   - Dedicated provider for retry-enabled Canvas calls
   - (Currently not used, but available for future use)

## Testing

### Manual Testing Steps

1. **Cold Start Test**:
   ```bash
   flutter clean
   flutter run
   # Sign in with a fresh session
   # Verify assignments load without sign-out
   ```

2. **Retry Test**:
   - Simulate network issues by turning off network briefly
   - App should retry automatically
   - Should show "Connection issue detected. Retrying..." message
   - Should not sign out on first error

3. **Consecutive Error Test**:
   - Force multiple consecutive auth errors
   - App should show warnings (1/3, 2/3)
   - Should only sign out on 3rd consecutive error
   - Counter should reset after 10 seconds

4. **Success Path Test**:
   - Normal login flow
   - Assignments load successfully
   - No warnings or sign-outs

### Expected Behavior

**Before Fix**:
- ❌ First 401 error immediately signs out user
- ❌ User redirected to login page
- ❌ Delayed success response is ignored

**After Fix**:
- ✅ First error shows warning with retry option
- ✅ Automatic retry with exponential backoff
- ✅ Only sign out after 3 consecutive errors
- ✅ Better error messages and UX

## Rollback Plan

If issues arise, you can revert to the original behavior by:

1. Remove the retry logic from `canvasAssignmentsWithUserProvider`
2. Remove the consecutive error tracking from `home_page.dart`
3. Restore immediate sign-out on auth errors

## Future Improvements

1. **Add Circuit Breaker Pattern**:
   - Stop retrying after N failures
   - Open circuit for cooldown period
   - Try again after cooldown

2. **Add Request Deduplication**:
   - Prevent multiple concurrent requests to same endpoint
   - Share results between providers

3. **Add Offline Support**:
   - Cache successful responses
   - Show cached data when offline
   - Sync when connection restored

4. **Better Session Validation**:
   - Pre-validate JWT before API calls
   - Refresh token before expiry
   - Handle token refresh gracefully

## Monitoring

Add these metrics to track effectiveness:

```dart
// Track retry success rate
final retrySuccessRate = successfulRequests / totalRequests;

// Track consecutive errors
final avgConsecutiveErrors = totalAuthErrors / uniqueSessions;

// Track time to first success
final avgTimeToSuccess = totalTimeToSuccess / successfulRequests;
```

## Related Issues

This fix addresses:
- Race conditions in authentication
- Transient network issues
- JWT propagation delays
- Over-aggressive error handling

## References

- Exponential Backoff: https://en.wikipedia.org/wiki/Exponential_backoff
- Circuit Breaker Pattern: https://martinfowler.com/bliki/CircuitBreaker.html
- Retry Strategies: https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
