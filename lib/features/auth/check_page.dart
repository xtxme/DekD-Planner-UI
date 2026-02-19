import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/forgot_page.dart';
import 'package:my_first_app/features/auth/login_page.dart';
import 'package:my_first_app/features/auth/widgets/auth_primary_button.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cFFFBFAF9,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
              child: Column(children: const [_CheckMailHeader()]),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            AuthPrimaryButton(
                              label: 'Back To Login',
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Did not receive the email?",
                                  style: TextStyle(
                                    color: AppColors.cFFA48C7E,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Resend Email',
                                    style: TextStyle(
                                      color: AppColors.cFFD9A441,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckMailHeader extends StatelessWidget {
  const _CheckMailHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          width: 96,
          height: 96,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cFFF4EBDD,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Icon(
              Icons.mark_email_read_sharp,
              size: 44,
              color: AppColors.cFFD2A34A,
            ),
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Check your mail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.cFF7A5A4A,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "We have sent password recovery\ninstructions to your email address.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.cFFA48C7E,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
