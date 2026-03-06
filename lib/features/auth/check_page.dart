import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/auth/login_page.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/features/auth/reset_password_page.dart';
import 'package:my_first_app/features/auth/widgets/auth_primary_button.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class CheckPage extends ConsumerStatefulWidget {
  const CheckPage({super.key});

  @override
  ConsumerState<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends ConsumerState<CheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    if (_isSubmitting) return;
    if (_formKey.currentState?.validate() != true) return;

    final email = _emailController.text.trim();
    setState(() => _isSubmitting = true);

    try {
      await ref.read(authRemoteServiceProvider).sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Please check your inbox and click the link.',
          ),
        ),
      );
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending reset email: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFBFAF9,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.cFFF4EBDD,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.cFF7A5A4A,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cFF7A5A4A,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.cFF7A5A4A,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your email address and we'll send\nyou instructions to reset your password.",
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.cFFA48C7E,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cFF7A5A4A,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
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
                            contentPadding: const EdgeInsets.symmetric(
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
                        const SizedBox(height: 28),
                        AuthPrimaryButton(
                          label: _isSubmitting ? 'Sending...' : 'confirm',
                          onPressed: _isSubmitting ? null : _onSubmitPressed,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Remember your password?",
                              style: TextStyle(
                                color: AppColors.cFFA48C7E,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Login',
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
          ],
        ),
      ),
    );
  }
}

class _CheckMailHeader extends StatelessWidget {
  const _CheckMailHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          width: 96,
          height: 96,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cFFF4EBDD,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Icon(
              Icons.mark_email_read_sharp,
              size: 44,
              color: AppColors.cFFD2A34A,
            ),
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Check your mail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.cFF7A5A4A,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "We have sent password recovery\ninstructions to your email address.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.cFFA48C7E,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
