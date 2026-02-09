import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AssignmentDetailStatCard extends StatelessWidget {
  const AssignmentDetailStatCard({
    super.key,
    required this.icon,
    required this.iconForeground,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconForeground;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackground,
            ),
            child: Icon(icon, size: 30, color: iconForeground),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            softWrap: true,
            style: const TextStyle(
              fontSize: 20 / 1.2,
              height: 1.25,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
