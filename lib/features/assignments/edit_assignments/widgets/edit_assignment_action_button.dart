import 'package:flutter/material.dart';

import 'edit_assignment_colors.dart';

class EditAssignmentActionButton extends StatelessWidget {
  const EditAssignmentActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? EditAssignmentColors.saveBackground
              : EditAssignmentColors.deleteBackground,
          foregroundColor: isPrimary
              ? EditAssignmentColors.saveForeground
              : EditAssignmentColors.delete,
          side: isPrimary
              ? null
              : const BorderSide(color: EditAssignmentColors.delete),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
