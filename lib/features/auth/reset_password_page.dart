import 'package:flutter/material.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/password_text_form_field.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFBFAF9,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
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
                          'Set Password',
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + subtitle
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Set New Password',
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
                        'Your new password must be different from\npreviously used passwords.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.cFFA48C7E,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // New password label + field + helper
                      const SizedBox(height: 22),
                      Text(
                        'New Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cFF7A5A4A,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PasswordTextFormField(
                        controller: _newPasswordController,
                        hintText: 'Create a new password',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a new password.';
                          }
                          if (value.trim().length < 8) {
                            return 'Password must be at least 8 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Must be at least 8 characters.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cFFA48C7E,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Confirm New Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cFF7A5A4A,
                        ),
                      ),
                      // Confirm label + field
                      const SizedBox(height: 8),
                      PasswordTextFormField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm your password',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password.';
                          }
                          if (value.trim() !=
                              _newPasswordController.text.trim()) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                      // Reset button
                      const SizedBox(height: 28),
                      AuthPrimaryButton(
                        label: 'Reset Password',
                        onPressed: () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
