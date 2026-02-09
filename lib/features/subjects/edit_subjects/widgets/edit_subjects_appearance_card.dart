import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

String _hexColor(Color color) {
  final rgb = color.value.toRadixString(16).padLeft(8, '0').substring(2);
  return '#${rgb.toUpperCase()}';
}

Color _checkIconColorFor(Color color) {
  return color.computeLuminance() > 0.6 ? Colors.black87 : Colors.white;
}

String _iconSemanticLabel(IconData icon) {
  if (icon == Icons.calculate_rounded) {
    return 'Calculator icon';
  }
  if (icon == Icons.science_rounded) {
    return 'Science icon';
  }
  if (icon == Icons.menu_book_rounded) {
    return 'Book icon';
  }
  if (icon == Icons.palette_rounded) {
    return 'Palette icon';
  }
  if (icon == Icons.public_rounded) {
    return 'Global icon';
  }
  return 'Subject icon';
}

class EditSubjectsAppearanceCard extends StatelessWidget {
  const EditSubjectsAppearanceCard({
    super.key,
    required this.colorChoices,
    required this.selectedColor,
    required this.iconChoices,
    required this.selectedIcon,
    required this.onColorTap,
    required this.onAddColorTap,
    required this.onIconTap,
    required this.onAddIconTap,
  });

  final List<Color> colorChoices;
  final Color selectedColor;
  final List<IconData> iconChoices;
  final IconData selectedIcon;
  final ValueChanged<Color> onColorTap;
  final VoidCallback onAddColorTap;
  final ValueChanged<IconData> onIconTap;
  final VoidCallback onAddIconTap;

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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              ...colorChoices.map(
                (color) => _ColorChoice(
                  color: color,
                  selected: color == selectedColor,
                  onTap: () => onColorTap(color),
                ),
              ),
              _AddColorChoice(onTap: onAddColorTap),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.border,
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ...iconChoices.map(
                (icon) => _IconChoice(
                  icon: icon,
                  selected: icon == selectedIcon,
                  selectedColor: selectedColor,
                  onTap: () => onIconTap(icon),
                ),
              ),
              _AddIconChoice(onTap: onAddIconTap),
            ],
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
    final colorHex = _hexColor(color);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Color $colorHex',
      hint: selected ? 'Selected' : 'Double tap to select this color',
      child: Tooltip(
        message: 'Color $colorHex',
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      color: _checkIconColorFor(color),
                      size: 32,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddColorChoice extends StatelessWidget {
  const _AddColorChoice({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add custom color',
      hint: 'Double tap to open color picker',
      child: Tooltip(
        message: 'Add custom color',
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.secondaryText,
              size: 30,
            ),
          ),
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
    final semanticLabel = _iconSemanticLabel(icon);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      hint: selected ? 'Selected' : 'Double tap to select this icon',
      child: Tooltip(
        message: semanticLabel,
        child: InkWell(
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
        ),
      ),
    );
  }
}

class _AddIconChoice extends StatelessWidget {
  const _AddIconChoice({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add custom icon',
      hint: 'Double tap to add a new icon',
      child: Tooltip(
        message: 'Add custom icon',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.secondaryText,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
