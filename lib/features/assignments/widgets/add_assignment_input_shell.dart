import 'package:flutter/material.dart';

class AddAssignmentInputShell extends StatelessWidget {
  const AddAssignmentInputShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.minHeight = 70,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6DBD2)),
      ),
      child: child,
    );
  }
}
