import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';
import 'package:my_first_app/shared/widgets/navbar/navbar_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'forgot_page.dart';
import 'register_page.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/password_text_form_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_isSubmitting) {
      return;
    }
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(authRemoteServiceProvider); //UI เรียกใช้งาน
      final signedInUser = await service.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (signedInUser == null) {
        throw StateError('Login completed without a user session.');
      }

      _logSessionDiagnostics();
      await ref.read(authLocalCacheDaoProvider).saveSession(signedInUser);
      ref.invalidate(authSessionProvider);

      await _waitForSessionReady();

      // ✅ Validate session หนึ่งครั้ง
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;

      if (session == null) {
        debugPrint('AUTH_DEBUG: ❌ Session is null after _waitForSessionReady');
        throw StateError('Session not ready. Please try again.');
      }

      debugPrint('AUTH_DEBUG: ✅ Session validated before navigation');
      debugPrint('AUTH_DEBUG: User ID: ${session.user.id}');
      debugPrint('AUTH_DEBUG: User Email: ${session.user.email}');

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavbarShell()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _waitForSessionReady() async {
    final client = Supabase.instance.client;
    for (var i = 0; i < 50; i++) {
      if (client.auth.currentSession != null) {
        debugPrint('AUTH_DEBUG: session ready after ${i * 100}ms');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    debugPrint('AUTH_DEBUG: session not ready after 5s, proceeding anyway');
  }

  void _logSessionDiagnostics() {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) {
      debugPrint('AUTH_DEBUG: login completed but currentSession is null');
      return;
    }

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    final tokenPayload = _decodeJwtPayload(session.accessToken);
    final sessionId = tokenPayload['session_id']?.toString() ?? '';

    debugPrint('AUTH_DEBUG: ===== LOGIN SESSION =====');
    debugPrint('AUTH_DEBUG: SUPABASE_URL=$supabaseUrl');
    debugPrint('AUTH_DEBUG: SUPABASE_ANON_KEY=$anonKey');
    debugPrint('AUTH_DEBUG: USER_ID=${session.user.id}');
    debugPrint('AUTH_DEBUG: SESSION_ID=$sessionId');
    debugPrint('AUTH_DEBUG: EXPIRES_AT=${session.expiresAt}');
    debugPrint('AUTH_DEBUG: ACCESS_TOKEN=${session.accessToken}');
    debugPrint('AUTH_DEBUG: CURL_START');
    debugPrint('curl -i "$supabaseUrl/auth/v1/user" \\');
    debugPrint('  -H "apikey: $anonKey" \\');
    debugPrint('  -H "Authorization: Bearer ${session.accessToken}"');
    debugPrint('AUTH_DEBUG: CURL_END');
    debugPrint('AUTH_DEBUG: =========================');
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return const {};
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return const {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFBFAF9,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.cFFF4EBDD,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                              child: const Icon(
                                Icons.school_sharp,
                                size: 44,
                                color: AppColors.cFFD2A34A,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Welcome back!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: AppColors.cFF7A5A4A,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sign in to continue planning your studies.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.cFFA48C7E,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email Address',
                                    style: TextStyle(
                                      color: AppColors.cFF7A5A4A,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your email.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'student@gmail.com',
                                      hintStyle: const TextStyle(
                                        color: AppColors.cFFB8A99A,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.mail_rounded,
                                        color: AppColors.cFFA9998B,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.cFFD9C6B4,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.cFFD9C6B4,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.cFFD2A34A,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      color: AppColors.cFF7A5A4A,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  PasswordTextFormField(
                                    controller: _passwordController,
                                    hintText: 'Enter your password',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            AuthPrimaryButton(
                              label: _isSubmitting ? 'Signing in...' : 'Login',
                              onPressed: _isSubmitting ? null : _onLoginPressed,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.cFFA48C7E,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account?",
                                  style: TextStyle(
                                    color: AppColors.cFFA48C7E,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    ' Register Now',
                                    style: TextStyle(
                                      color: AppColors.cFFD9A441,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
