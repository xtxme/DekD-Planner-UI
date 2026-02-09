import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class EditSubjectsFieldShell extends StatelessWidget {
  const EditSubjectsFieldShell({
    super.key,
    required this.child,
    this.minHeight = 72,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
    this.isFocused = false,
  });

  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(minHeight: minHeight),
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFocused ? AppColors.accent : AppColors.border,
          width: isFocused ? 1.6 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
