import 'package:flutter/material.dart';
import 'forgot_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget{
  const LoginPage ({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  
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
                      //ไอคอน + Welcome back
                      children:  [
                      SizedBox(height: 56),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4EBDD),
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Icon(
                          Icons.school_sharp,
                          size: 44,
                          color: Color(0xFFD2A34A),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Welcome back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7A5A4A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sign in to continue planning your studies.',
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
                            const SizedBox(height: 20),
                            Text(
                              'Password',
                              style: TextStyle(
                                color: Color(0xFF7A5A4A),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: Color(0xFFB8A99A),
                                ),
                                prefixIcon: Icon(Icons.lock, color: Color(0xFFA9998B)),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword; //toggle ค่า
                                    });
                                }, 
                                icon: Icon( //_obscurePassword == true แสดงไอคอนตาปิด
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                ),
                                ),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      //ปุ่มLogin + ลิงก์ Forgot/Register 
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {}, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD9A441),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          ),
                          child: const Text('Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                          ),
                        ),
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
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA48C7E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                          style: TextStyle(
                            color: Color(0xFFA48C7E),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            ),
                          ),
                          TextButton(onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                          },                           
                          child: Text(' Register Now',
                          style: TextStyle(
                            color: Color(0xFFD9A441),
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
            );
          },
        ),
      ),
    );
  }
}
