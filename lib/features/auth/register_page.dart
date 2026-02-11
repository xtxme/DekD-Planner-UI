import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';
import 'package:my_first_app/shared/widgets/navbar/navbar_shell.dart';

import 'widgets/auth_primary_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
    if (_isSubmitting) {
      return;
    }
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(authRemoteServiceProvider); //UI เรียกใช้งาน
      await service.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
      );
      ref.invalidate(authSessionProvider);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavbarShell()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: AppColors.cFFF4EBDD,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.cFF7A5A4A,
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Register',
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
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Create Your\nAccount',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.cFF7A5A4A,
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Start planning your success today.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: AppColors.cFFA48C7E,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.cFFF4EBDD,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      size: 28,
                                      color: AppColors.cFFD2A34A,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              buildField(
                                label: 'Name',
                                hint: 'Your Name',
                                icon: Icons.person_sharp,
                                keyboardType: TextInputType.name,
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              buildField(
                                label: 'Email Address',
                                hint: 'student@gmail.com',
                                icon: Icons.mail_rounded,
                                keyboardType: TextInputType.emailAddress,
                                enableSuggestions: false,
                                autocorrect: false,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              buildField(
                                label: 'Password',
                                hint: 'Create a password',
                                icon: Icons.lock,
                                isObscure: _obscurePassword,
                                controller: _passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                onToggle: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a password.';
                                  }
                                  if (value.trim().length < 8) {
                                    return 'Password must be at least 8 characters.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              buildField(
                                label: 'Confirm Password',
                                hint: 'Confirm your password',
                                icon: Icons.lock_reset_outlined,
                                isObscure: _obscureConfirm,
                                controller: _confirmPasswordController,
                                keyboardType: TextInputType.visiblePassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                onToggle: () => setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                }),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please confirm your password.';
                                  }
                                  if (value.trim() !=
                                      _passwordController.text.trim()) {
                                    return 'Passwords do not match.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),
                              AuthPrimaryButton(
                                label:
                                    _isSubmitting ? 'Registering...' : 'Register',
                                onPressed:
                                    _isSubmitting ? null : _onRegisterPressed,
                              ),
                              const SizedBox(height: 100),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: AppColors.cFFA48C7E,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: const Text(
                                      ' Login',
                                      style: TextStyle(
                                        color: AppColors.cFFD9A441,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}

Widget buildField({
  required String label,
  required String hint,
  required IconData icon,
  bool obscure = false,
  bool? isObscure,
  VoidCallback? onToggle,
  TextEditingController? controller,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
  bool enableSuggestions = true,
  bool autocorrect = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.cFF7A5A4A,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isObscure ?? obscure,
        enableSuggestions: enableSuggestions,
        autocorrect: autocorrect,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.cFFA48C7E,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppColors.cFFA9998B),
          suffixIcon: onToggle == null
              ? null
              : IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    (isObscure ?? true)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.cFFB08F7E,
                  ),
                ),
          filled: true,
          fillColor: AppColors.cFFF3ECE6,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
