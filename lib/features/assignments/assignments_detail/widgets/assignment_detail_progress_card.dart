import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailProgressCard extends StatelessWidget {
  const AssignmentDetailProgressCard({
    super.key,
    required this.progressPercentage,
  });

  final int progressPercentage;

  @override
  Widget build(BuildContext context) {
    final progressText = progressPercentage == 0
        ? 'Not Started'
        : '$progressPercentage% Complete';

    final progressColor = progressPercentage == 0
        ? AppColors.textSecondary
        : progressPercentage == 100
        ? const Color(0xFF1C9E73)
        : const Color(0xFF2E64D4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESS',
                style: const TextStyle(
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
