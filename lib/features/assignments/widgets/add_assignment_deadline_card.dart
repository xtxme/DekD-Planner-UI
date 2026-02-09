import 'package:flutter/material.dart';

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
                      color: Color(0xFFA48C7E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA48C7E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onSelectTime,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFA48C7E),
              side: const BorderSide(color: Color(0xFFE2D8CF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: Text(
              timeText,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onSelectDate,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF5EFE4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 28,
                color: Color(0xFFD6A95A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
