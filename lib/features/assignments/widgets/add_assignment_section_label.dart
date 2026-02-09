import 'package:flutter/material.dart';

class AddAssignmentSectionLabel extends StatelessWidget {
  const AddAssignmentSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF8B6758),
      ),
    );
  }
}
