import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage ({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _obscureNew = true;
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
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Create a new password',
                        hintStyle: TextStyle(
                          color: Color(0xFFB8A99A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.mail_rounded, color: Color(0xFFA9998B)),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                          _obscureNew = !_obscureNew;
                        }), 
                          icon: Icon(
                             _obscureNew? Icons.visibility_off : Icons.visibility,
                             color: Color(0xFFB08F7E),
                          ),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
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
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        hintStyle: TextStyle(
                          color: Color(0xFFB8A99A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(Icons.mail_rounded, color: Color(0xFFA9998B)),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                          _obscureNew = !_obscureNew;
                        }), 
                          icon: Icon(
                             _obscureNew? Icons.visibility_off : Icons.visibility,
                             color: Color(0xFFB08F7E),
                          ),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    // Reset button
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity, //ขยายความกว้างให้เต็มพื้นที่ที่ parent อนุญาต
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
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
            ],
          ),
        ),
      ),
    );
  }
}
