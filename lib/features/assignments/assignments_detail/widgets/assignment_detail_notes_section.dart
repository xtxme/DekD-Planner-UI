import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import 'assignment_detail_notes_card.dart';

class AssignmentDetailNotesSection extends StatelessWidget {
  const AssignmentDetailNotesSection({
    super.key,
    required this.notesText,
    this.notesHtml,
  });

  final String notesText;
  final String? notesHtml;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOTES & INSTRUCTIONS',
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        AssignmentDetailNotesCard(text: notesText, htmlText: notesHtml),
      ],
    );
  }
}
