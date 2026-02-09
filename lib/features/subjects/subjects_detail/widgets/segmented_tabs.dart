import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class SubjectSegmentedTabs extends StatelessWidget {
  const SubjectSegmentedTabs({
    super.key,
    required this.isUpcoming,
    required this.onUpcomingTap,
    required this.onCompletedTap,
  });

  final bool isUpcoming;
  final VoidCallback onUpcomingTap;
  final VoidCallback onCompletedTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cFFE6DED6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Upcoming',
            selected: isUpcoming,
            onTap: onUpcomingTap,
          ),
          _TabButton(
            label: 'Completed',
            selected: !isUpcoming,
            onTap: onCompletedTap,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label assignments tab',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: selected ? AppColors.cFF8B6758 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.cFFA48C7E,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
