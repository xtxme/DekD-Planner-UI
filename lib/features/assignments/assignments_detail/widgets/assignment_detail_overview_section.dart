import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailOverviewSection extends StatelessWidget {
  const AssignmentDetailOverviewSection({
    super.key,
    required this.title,
    required this.dueText,
  });

  final String title;
  final String dueText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.event_note_rounded,
              size: 22,
              color: AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              dueText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
