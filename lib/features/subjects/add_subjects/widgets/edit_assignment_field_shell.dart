import 'package:flutter/material.dart';

import 'edit_assignment_colors.dart';

class EditAssignmentFieldShell extends StatelessWidget {
  const EditAssignmentFieldShell({
    super.key,
    required this.child,
    this.minHeight = 68,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    this.isError = false,
    this.borderColorOverride,
  });

  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final bool isError;
  final Color? borderColorOverride;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        borderColorOverride ??
        (isError ? EditAssignmentColors.delete : EditAssignmentColors.border);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: EditAssignmentColors.headerBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
