import 'package:flutter/material.dart';

import 'widgets/auth_primary_button.dart';
class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //เตรียมโครงหน้า
      backgroundColor: const Color(0xFFFBFAF9),
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
                      //App bar
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
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF7A5A4A),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 48,)
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
                              const SizedBox(height: 24),
                              //หัวเรื่องใหญ่ + ไอคอนหมวก
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Create Your\nAccount",
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF7A5A4A),
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Start planning your success today.",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFFA48C7E),
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
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF4EBDD),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.school,
                                      size: 28,
                                      color: Color(0xFFD2A34A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              // input fields
                              buildField(
                                label: "Name",
                                hint: "Your Name",
                                icon: Icons.person_sharp,
                              ),
                              const SizedBox(height: 20),
                              buildField(
                                label: "Email Address",
                                hint: "student@gmail.com",
                                icon: Icons.mail_rounded,
                              ),
                              const SizedBox(height: 20),
                              buildField(
                                label: "Password",
                                hint: "Create a password",
                                icon: Icons.lock,
                                isObscure: _obscurePassword,
                                controller: _passwordController,
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
                                label: "Confirm Password",
                                hint: "Confirm your password",
                                icon: Icons.lock_reset_outlined,
                                isObscure: _obscureConfirm,
                                controller: _confirmPasswordController,
                                onToggle: () => setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                }),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please confirm your password.';
                                  }
                                  if (value.trim() != _passwordController.text.trim()) {
                                    return 'Passwords do not match.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),
                              AuthPrimaryButton(
                                label: 'Register',
                                onPressed: () {
                                  if (_formKey.currentState?.validate() != true) {
                                    return;
                                  }
                                },
                              ),
                              const SizedBox(height: 100),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: Color(0xFFA48C7E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, "/login");
                                    },
                                    child: Text(
                                      " Login",
                                      style: TextStyle(
                                        color: Color(0xFFD9A441),
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
              )
            );
          },
        ),
      ),
    );
  }
}

 //helper widget สร้าง input fields
Widget buildField({
  required String label,
  required String hint,
  required IconData icon,
  bool obscure = false, //ซ่อนตัวอักษรหรือไม่ (password)
  bool? isObscure, //กำลังซ่อนข้อความอยู่ไหม
  VoidCallback? onToggle, //ใช้เรียกตอนผู้ใช้ กดปุ่มสลับซ่อน/แสดงรหัสผ่าน
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Color(0xFF7A5A4A),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isObscure ?? obscure,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Color(0xFFA48C7E),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Color(0xFFA9998B)),
          suffixIcon: onToggle == null
              ? null
              : IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    (isObscure ?? true)
                        ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFFB08F7E),
                  ),
                ),
          filled: true,
          fillColor: Color(0xFFF3ECE6),
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
