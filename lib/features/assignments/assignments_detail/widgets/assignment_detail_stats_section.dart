import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import 'assignment_detail_stat_card.dart';

class AssignmentDetailStatsSection extends StatelessWidget {
  const AssignmentDetailStatsSection({
    super.key,
    required this.subject,
    required this.status,
  });

  final String subject;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AssignmentDetailStatCard(
            icon: Icons.functions_rounded,
            iconForeground: AppColors.cFF2E64D4,
            iconBackground: AppColors.cFFDCE7FF,
            label: 'SUBJECT',
            value: subject,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AssignmentDetailStatCard(
            icon: Icons.more_horiz_rounded,
            iconForeground: AppColors.cFFE0B35D,
            iconBackground: AppColors.cFFFFF8EA,
            label: 'STATUS',
            value: status,
          ),
        ),
      ],
    );
  }
}
