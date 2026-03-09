import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';
import 'assignment_detail_time_remaining_badge.dart';

class AssignmentDetailHeroSection extends StatelessWidget {
  const AssignmentDetailHeroSection({
    super.key,
    required this.title,
    required this.timeRemaining,
    required this.timeRemainingColor,
    required this.dueText,
  });

  final String title;
  final String timeRemaining;
  final Color timeRemainingColor;
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
        const SizedBox(height: 12),
        AssignmentDetailTimeRemainingBadge(
          timeRemaining: timeRemaining,
          color: timeRemainingColor,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_rounded,
              size: 22,
              color: AppColors.cFFE54A4A,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dueText,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cFFE54A4A,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
