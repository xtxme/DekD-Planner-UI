import 'package:flutter/material.dart';

import 'edit_assignment_colors.dart';

class EditAssignmentActionButton extends StatelessWidget {
  const EditAssignmentActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isPrimary
        ? EditAssignmentColors.saveForeground
        : EditAssignmentColors.delete;
    final buttonEnabled = enabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton.icon(
        onPressed: buttonEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? EditAssignmentColors.saveBackground
              : EditAssignmentColors.deleteBackground,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: isPrimary
              ? EditAssignmentColors.saveBackground.withValues(alpha: 0.6)
              : EditAssignmentColors.deleteBackground.withValues(alpha: 0.9),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
          side: isPrimary
              ? null
              : const BorderSide(color: EditAssignmentColors.delete),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: foregroundColor,
                ),
              )
            : Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
