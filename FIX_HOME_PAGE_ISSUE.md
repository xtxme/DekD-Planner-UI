## 🔧 Fix Proposals for Home Page Canvas Data Loading Issue

### ✅ Fix 1: Add Debug Logging to Track Session State

**File:** `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

```dart
Future<CanvasAssignmentsResponse> fetchAssignmentsWithUser() async {
  debugPrint('CANVAS_DEBUG: Starting fetchAssignmentsWithUser()');
  
  final session = _client.auth.currentSession;
  debugPrint('CANVAS_DEBUG: Current session: ${session != null ? "EXISTS" : "NULL"}');
  
  if (session != null) {
    final payload = _decodeJwtPayload(session.accessToken);
    debugPrint('CANVAS_DEBUG: Session user_id=${session.user.id}');
    debugPrint('CANVAS_DEBUG: Session expires_at=${session.expiresAt}');
    debugPrint('CANVAS_DEBUG: Session token_preview=${session.accessToken.substring(0, 50)}...');
  }

  await requireActiveSession();

  try {
    final response = await invokeAssignmentsProxy();
    debugPrint('CANVAS_DEBUG: Proxy response status=${response.status}');
    
    if (response.status >= 400) {
      debugPrint('CANVAS_DEBUG: Proxy error response: ${response.data}');
    }
    
    // ... rest of code
  } catch (e) {
    debugPrint('CANVAS_DEBUG: Exception caught: $e');
    rethrow;
  }
}

Map<String, dynamic> _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return {};
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {}
  return {};
}
```

---

### ✅ Fix 2: Improve Session Wait Logic in Login Page

**File:** `lib/features/auth/login_page.dart`

```dart
Future<void> _onLoginPressed() async {
  if (_isSubmitting) return;
  if (_formKey.currentState?.validate() != true) return;

  setState(() => _isSubmitting = true);

  try {
    final service = ref.read(authRemoteServiceProvider);
    final signedInUser = await service.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (signedInUser == null) {
      throw StateError('Login completed without a user session.');
    }

    _logSessionDiagnostics();
    await ref.read(authLocalCacheDaoProvider).saveSession(signedInUser);
    
    // ✅ Invalidate provider เพื่อให้ refetch ใหม่
    ref.invalidate(authSessionProvider);
    
    // ✅ รอ session พร้อมอย่างแน่นอน
    await _waitForSessionReady();

    // ✅ Validate session หนึ่งครั้ง
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    
    if (session == null) {
      throw StateError('Session not ready after login. Please try again.');
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavbarShell()),
      (route) => false,
    );
  } on AuthException catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message))
    );
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $error'))
    );
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
```

---

### ✅ Fix 3: Add Loading State in HomePage Before Fetching

**File:** `lib/features/home/home_page.dart`

```dart
@override
Widget build(BuildContext context) {
  final authSession = ref.watch(authSessionProvider);
  final assignmentsAsync = ref.watch(homeCanvasAssignmentSectionsProvider);
  
  // ✅ ถ้า session ยัง loading ให้แสดง loading state
  if (authSession.isLoading) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
  
  // ✅ ถ้าไม่มี session แต่อยู่ใน home page → redirect ไป login
  if (!authSession.hasValue || authSession.value == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  // ... rest of build method
}
```

---

### ✅ Fix 4: Use AutomaticKeepAliveClientMixin to Prevent Rebuild

**File:** `lib/features/home/home_page.dart`

```dart
class _HomePageState extends ConsumerState<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ รักษา state ของ widget

  // ... rest of code
}
```

---

### ✅ Fix 5: Improve Error Handling in Canvas Assignment Remote Data Source

**File:** `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

```dart
Future<CanvasAssignmentsResponse> fetchAssignmentsWithUser() async {
  await requireActiveSession();

  try {
    final response = await invokeAssignmentsProxy();

    if (_isAuthFailureStatus(response.status, response.data)) {
      debugPrint('CANVAS_DEBUG: Auth failure detected');
      throw const CanvasSessionExpiredException();
    }

    if (response.status >= 400) {
      final errorMsg = _extractErrorMessage(response.data);
      debugPrint('CANVAS_DEBUG: Error response: $errorMsg');
      throw Exception(errorMsg);
    }

    final data = response.data;
    if (data is! Map) {
      debugPrint('CANVAS_DEBUG: Invalid response format');
      throw const FormatException(
        'Canvas assignments proxy returned an invalid response.',
      );
    }

    debugPrint('CANVAS_DEBUG: Successfully fetched ${data['assignments']?.length ?? 0} assignments');
    return CanvasAssignmentsResponse.fromMap(Map<String, dynamic>.from(data));
  } on FunctionException catch (error) {
    debugPrint('CANVAS_DEBUG: FunctionException: ${error.message}');
    debugPrint('CANVAS_DEBUG: Status: ${error.status}');
    debugPrint('CANVAS_DEBUG: Details: ${error.details}');
    
    if (_isAuthFailure(error)) {
      throw const CanvasSessionExpiredException();
    }
    throw Exception(_extractErrorMessage(error.details));
  } on AuthException catch (error) {
    debugPrint('CANVAS_DEBUG: AuthException: ${error.message}');
    throw const CanvasSessionExpiredException();
  } catch (error, stackTrace) {
    debugPrint('CANVAS_DEBUG: Unexpected error: $error');
    debugPrint('CANVAS_DEBUG: Stack trace: $stackTrace');
    rethrow;
  }
}
```

---

### ✅ Fix 6: Add Session State Listener in NavbarShell

**File:** `lib/shared/widgets/navbar/navbar_shell.dart`

```dart
class NavbarShell extends ConsumerStatefulWidget {
  const NavbarShell({super.key});

  @override
  ConsumerState<NavbarShell> createState() => _NavbarShellState();
}

class _NavbarShellState extends ConsumerState<NavbarShell> {
  StreamSubscription<AuthState>? _authStateSub;

  @override
  void initState() {
    super.initState();
    
    // ✅ Listen to auth state changes
    _authStateSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomePage(),
          SubjectsPage(withNavBar: false),
          AssignmentsPage(withNavBar: false),
          SettingsPage(withNavBar: false),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(currentNavIndexProvider.notifier).state = index,
      ),
    );
  }
}
```

---

## 🧪 Testing Steps

หลังจาก apply fixes ให้ทดสอบตามนี้:

### 1. Test Session Logging
```bash
flutter run
# Login และดู debug output ว่ามี CANVAS_DEBUG logs หรือไม่
```

### 2. Test Auth Flow
- Login ด้วย email/password ที่ถูกต้อง
- ดูว่า session ถูกสร้างหรือไม่ (จาก AUTH_DEBUG logs)
- ดูว่า navigate ไป home page สำเร็จหรือไม่

### 3. Test Error Scenarios
- Login แล้วรอ session ไม่พร้อม (สังเกต loading state)
- Logout แล้วดูว่า redirect ไป login page หรือไม่
- Network ไม่มี connection (สังเกต error handling)

### 4. Test Edge Function Directly
```bash
# Test ด้วย anon key (ควรได้ 401)
curl -s "https://lhtffjttpachjjntvssj.supabase.co/functions/v1/canvas-assignments-proxy" \
  -H "apikey: <ANON_KEY>"

# Test หลังจาก login (ดู token จาก Flutter logs)
curl -s "https://lhtffjttpachjjntvssj.supabase.co/functions/v1/canvas-assignments-proxy" \
  -H "Authorization: Bearer <USER_ACCESS_TOKEN>" \
  -H "apikey: <ANON_KEY>"
```

---

## 📝 Summary of Changes

| Fix | File | Description |
|-----|------|-------------|
| 1 | `canvas_assignment_remote_data_source.dart` | Add comprehensive debug logging |
| 2 | `login_page.dart` | Improve session validation before navigation |
| 3 | `home_page.dart` | Add loading and auth state checks |
| 4 | `home_page.dart` | Use AutomaticKeepAliveClientMixin |
| 5 | `canvas_assignment_remote_data_source.dart` | Improve error handling and logging |
| 6 | `navbar_shell.dart` | Add auth state listener |

---

## 🎯 Recommended Priority

1. **HIGH PRIORITY:** Fix #1 (Debug Logging) - เพื่อระบุปัญหาแน่ชัด
2. **HIGH PRIORITY:** Fix #2 (Session Validation) - ป้องกัน navigate เมื่อไม่มี session
3. **MEDIUM PRIORITY:** Fix #3 (Loading State) - ประสบการณ์ user ที่ดีขึ้น
4. **MEDIUM PRIORITY:** Fix #5 (Error Handling) - debug ง่ายขึ้น
5. **LOW PRIORITY:** Fix #4, #6 - เป็น optional improvements

---

## 📞 Next Steps

1. Apply Fix #1 ก่อน เพื่อดู debug logs
2. Run app และดู logs ว่าปัญหาอยู่ที่ไหน
3. Apply fixes ตามลำดับความสำคัญ
4. Test และ verify แต่ละ fix
5. ถ้ายังไม่ได้ ส่ง logs มาให้ผมวิเคราะห์ต่อ
