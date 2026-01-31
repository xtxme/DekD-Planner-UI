import 'package:flutter/material.dart';
import 'package:path/path.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //เตรียมโครงหน้า
      backgroundColor: const Color(0xFFFBFAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //App bar
                Row(
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
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7A5A4A),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48,)
                  ],
                ),
                const SizedBox(height: 24),
                //หัวเรื่องใหญ่ + ไอคอนหมวก
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Create Your\nAccount",
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
                  suffix: Icon(Icons.visibility_off, color: Color(0xFFB08F7E)),
                  obscure: true,
                ),
                const SizedBox(height: 20),
                buildField(
                  label: "Confirm Password", 
                  hint: "Confirm your password", 
                  icon: Icons.lock_reset_outlined,
                  obscure: true,
                ),
              ],
            ),
          ),
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
      TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Color(0xFFA48C7E),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Color(0xFFA9998B)),
          suffixIcon: IconButton(onPressed: () {
            setState(() {
               _obscure = !_obscure
            })
          }, icon: icon),
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