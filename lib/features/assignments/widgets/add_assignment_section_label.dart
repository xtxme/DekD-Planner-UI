import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

class AddAssignmentSectionLabel extends StatelessWidget {
  const AddAssignmentSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}
