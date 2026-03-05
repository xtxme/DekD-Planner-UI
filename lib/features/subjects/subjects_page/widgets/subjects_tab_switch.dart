import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class SubjectsTabSwitch extends StatelessWidget {
  const SubjectsTabSwitch({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const _labels = ['My Subjects', 'Canvas Courses'];

  @override
  Widget build(BuildContext context) {
    const activeTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / _labels.length;
          final indicatorWidth = _measureLabelWidth(
            context: context,
            label: _labels[selectedIndex],
            style: activeTextStyle,
            maxWidth: tabWidth,
          );
          final indicatorLeft =
              (tabWidth * selectedIndex) + ((tabWidth - indicatorWidth) / 2);

          return Column(
            children: [
              Row(
                children: List.generate(_labels.length, (index) {
                  return Expanded(
                    child: _TabButton(
                      label: _labels[index],
                      selected: selectedIndex == index,
                      onTap: () => onSelected(index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 3,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      left: indicatorLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: indicatorWidth,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _measureLabelWidth({
    required BuildContext context,
    required String label,
    required TextStyle style,
    required double maxWidth,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: maxWidth);

    return textPainter.width;
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
