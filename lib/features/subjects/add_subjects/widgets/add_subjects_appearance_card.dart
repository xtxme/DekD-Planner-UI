import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class AddSubjectsAppearanceCard extends StatelessWidget {
  const AddSubjectsAppearanceCard({
    super.key,
    required this.colorChoices,
    required this.selectedColor,
    required this.iconChoices,
    required this.selectedIcon,
    required this.onColorTap,
    required this.onIconTap,
  });

  final List<Color> colorChoices;
  final Color selectedColor;
  final List<IconData> iconChoices;
  final IconData selectedIcon;
  final ValueChanged<Color> onColorTap;
  final ValueChanged<IconData> onIconTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colorChoices
                .map(
                  (color) => _ColorChoice(
                    color: color,
                    selected: color == selectedColor,
                    onTap: () => onColorTap(color),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.border,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: iconChoices
                .map(
                  (icon) => _IconChoice(
                    icon: icon,
                    selected: icon == selectedIcon,
                    selectedColor: selectedColor,
                    onTap: () => onIconTap(icon),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 62,
        height: 62,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: AppColors.textPrimary, width: 2)
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
              : null,
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? selectedColor : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? Colors.white : AppColors.secondaryText,
          size: 28,
        ),
      ),
    );
  }
}
