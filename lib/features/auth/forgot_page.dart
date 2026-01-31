import 'package:flutter/material.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF9),
      //วางโครงหลัก
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //ไอคอน + Forgot Password?
                      children: [
                        SizedBox(height: 56),
                        SizedBox(
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back_rounded, size: 18),
                              label: const Text('Back to Login'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF7A5A4A),
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
                            color: Color(0xFFF4EBDD),
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                          child: Icon(
                            Icons.question_mark_rounded,
                            size: 44,
                            color: Color(0xFFD2A34A),
                          ),
                        ),
                        SizedBox(height: 12),
                      Text(
                        'Forgot Password?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7A5A4A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Don't worry! It happens.\n" "Please enter the email associated with your account\n" "and we'll send you a reset link.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFA48C7E),
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 32),
                      //ทำฟอร์ม Email/Password
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: Color(0xFF7A5A4A),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'student@gmail.com',
                                hintStyle: TextStyle(
                                  color: Color(0xFFB8A99A),
                                ),
                                prefixIcon: Icon(Icons.mail_rounded, color: Color(0xFFA9998B)),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Color(0xFFD9C6B4)),
                                ),
                                //ขอบตอน ยังไม่กดพิมพ์
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Color(0xFFD9C6B4)),
                                ),
                                //ขอบตอน กำลังพิมพ์
                                focusedBorder:OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Color(0xFFD2A34A)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {}, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD9A441),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          ),
                          child: const Text('Send Reset Link',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
