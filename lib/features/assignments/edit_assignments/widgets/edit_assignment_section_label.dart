import 'package:flutter/material.dart';

import 'edit_assignment_colors.dart';

class EditAssignmentSectionLabel extends StatelessWidget {
  const EditAssignmentSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: EditAssignmentColors.sectionLabel,
      ),
    );
  }
}
