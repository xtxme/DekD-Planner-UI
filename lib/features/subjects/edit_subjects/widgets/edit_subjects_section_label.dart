import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class EditSubjectsSectionLabel extends StatelessWidget {
  const EditSubjectsSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }
}
