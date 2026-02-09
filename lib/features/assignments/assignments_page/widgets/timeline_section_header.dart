import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class TimelineSectionHeader extends StatelessWidget {
  const TimelineSectionHeader({
    super.key,
    required this.title,
    required this.taskCount,
  });

  final String title;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final taskLabel = '$taskCount ${taskCount == 1 ? 'Task' : 'Tasks'}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cFFE2D9D0,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
              color: AppColors.cFF8B6758,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Divider(thickness: 1, color: AppColors.cFFE3DBD3),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cFFF0E5D5,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            taskLabel,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.cFF8B6758,
            ),
          ),
        ),
      ],
    );
  }
}
