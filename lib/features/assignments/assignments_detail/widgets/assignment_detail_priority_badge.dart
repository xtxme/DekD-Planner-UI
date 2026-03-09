import 'package:flutter/material.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_priority_badge.dart';
import 'package:my_first_app/features/assignments/assignments_detail/widgets/assignment_detail_progress_card.dart';

class AssignmentDetailPriorityBadge extends StatelessWidget {
  const AssignmentDetailPriorityBadge({
    super.key,
    required this.priority,
    required this.color,
  });

  final String priority;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            priority,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
