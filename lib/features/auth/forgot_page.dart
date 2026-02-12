import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/auth/check_page.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import 'widgets/auth_primary_button.dart';

class ForgotPage extends ConsumerStatefulWidget {
  const ForgotPage({super.key});

  @override
  ConsumerState<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends ConsumerState<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendResetLinkPressed() async {
    if (_isSubmitting) return;
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(authRemoteServiceProvider).sendPasswordResetEmail(
            email: _emailController.text.trim(),
            redirectTo: 'dekdplanner://reset-password',
          );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckPage()),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If this email is registered, a reset link will be sent shortly.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 56),
                          SizedBox(
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                label: const Text('Back to Login'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.cFF7A5A4A,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.cFFF4EBDD,
                              borderRadius: const BorderRadius.all(Radius.circular(24)),
                            ),
                            child: const Icon(
                              Icons.question_mark_rounded,
                              size: 44,
                              color: AppColors.cFFD2A34A,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Forgot Password?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cFF7A5A4A,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Don't worry! It happens.\nPlease enter the email associated with your account\nand we'll send you a reset link.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.cFFA48C7E,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
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
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email.';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'student@gmail.com',
                                    hintStyle: const TextStyle(color: AppColors.cFFB8A99A),
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
                                      borderSide: const BorderSide(color: AppColors.cFFD9C6B4),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppColors.cFFD9C6B4),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppColors.cFFD2A34A),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                AuthPrimaryButton(
                                  label: _isSubmitting ? 'Sending...' : 'Send Reset Link',
                                  onPressed: _isSubmitting ? null : _onSendResetLinkPressed,
                                ),
                              ],
                            ),
                          ),
                        ],
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
