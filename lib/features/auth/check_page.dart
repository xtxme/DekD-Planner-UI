import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/widgets/auth_primary_button.dart';
import 'package:my_first_app/features/auth/register_page.dart';

class CheckPage extends StatefulWidget{
  const CheckPage ({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //สร้างไอคอนตรงกลาง
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4EBDD),
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Icon(
                          Icons.mark_email_read_sharp,
                          size: 44,
                          color: Color(0xFFD2A34A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Check your mail', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF7A5A4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We have sent password recovery\ninstructions to your email address.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFA48C7E),
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 40),
                      AuthPrimaryButton(
                        label: 'Back To Login',
                        onPressed: () => {},
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Did not receive the email?",
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
                          child: Text('Resend Email',
                          style: TextStyle(
                            color: Color(0xFFD9A441),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            ),
                          ),
                        ),
                        ],
                      ),
                    ]
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
