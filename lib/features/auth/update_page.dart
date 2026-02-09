import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/login_page.dart';
import 'package:my_first_app/features/auth/widgets/auth_primary_button.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.cFFFDF8F2, AppColors.cFFFFFAF5],
            ),
          ),
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
                        const _CheckMarkBadge(),
                        const SizedBox(height: 24),
                        const Text(
                          'Password Updated!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cFF8B6A5E,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your password has been successfully updated.\nYou can now log in to manage your assignments.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.cFFA48C7E,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        AuthPrimaryButton(
                          label: 'Back To Login',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CheckMarkBadge extends StatelessWidget {
  const _CheckMarkBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.cFFF6EAD8,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cFFF2DDC3, width: 2),
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: AppColors.cFFE1B873,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}
