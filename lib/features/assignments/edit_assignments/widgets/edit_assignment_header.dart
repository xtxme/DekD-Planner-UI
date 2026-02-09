import 'package:flutter/material.dart';

import 'edit_assignment_colors.dart';

class EditAssignmentHeader extends StatelessWidget {
  const EditAssignmentHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: const BoxDecoration(
        color: EditAssignmentColors.headerBackground,
        border: Border(bottom: BorderSide(color: EditAssignmentColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: EditAssignmentColors.title,
              size: 30,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: EditAssignmentColors.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
