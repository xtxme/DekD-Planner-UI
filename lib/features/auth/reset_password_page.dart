import 'package:flutter/material.dart';
import 'widgets/password_text_form_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage ({super.key});

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
      backgroundColor: const Color(0xFFFBFAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Container(
                width: double.infinity,
                color: const Color(0xFFF4EBDD),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF7A5A4A),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Set Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7A5A4A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            color: Color(0xFF7A5A4A),
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
                        color: Color(0xFFA48C7E),
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    // New password label + field + helper
                    const SizedBox(height: 22),
                    Text(
                      'New Password',
                      style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7A5A4A),
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
                        color: Color(0xFFA48C7E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Confirm New Password',
                      style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7A5A4A),
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
                        if (value.trim() != _newPasswordController.text.trim()) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    // Reset button
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity, //ขยายความกว้างให้เต็มพื้นที่ที่ parent อนุญาต
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6A75C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
