import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/theme/app_colors.dart';
import 'add_assignment_input_shell.dart';

class AddAssignmentDeadlineCard extends StatelessWidget {
  const AddAssignmentDeadlineCard({
    super.key,
    required this.dateText,
    required this.timeText,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final String dateText;
  final String timeText;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  @override
  Widget build(BuildContext context) {
    return AddAssignmentInputShell(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: 'Select assignment date',
              child: GestureDetector(
                onTap: onSelectDate,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DUE DATE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Select assignment time',
            child: OutlinedButton(
              onPressed: onSelectTime,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              child: Text(
                timeText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Open date picker',
            child: InkWell(
              onTap: onSelectDate,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 28,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
