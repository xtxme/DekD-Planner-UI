import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

enum ReminderPreset { oneDayBefore, sixHoursBefore, custom }

enum ReminderUnit { hoursBefore, daysBefore, weeksBefore }

extension ReminderUnitLabel on ReminderUnit {
  String get dropdownLabel {
    switch (this) {
      case ReminderUnit.hoursBefore:
        return 'Hours';
      case ReminderUnit.daysBefore:
        return 'Days';
      case ReminderUnit.weeksBefore:
        return 'Weeks';
    }
  }

  String countLabel(int amount) {
    switch (this) {
      case ReminderUnit.hoursBefore:
        return amount == 1 ? 'hour' : 'hours';
      case ReminderUnit.daysBefore:
        return amount == 1 ? 'day' : 'days';
      case ReminderUnit.weeksBefore:
        return amount == 1 ? 'week' : 'weeks';
    }
  }
}

class NotificationReminderCard extends StatelessWidget {
  const NotificationReminderCard({
    super.key,
    required this.selectedPreset,
    required this.onPresetChanged,
    required this.selectedAmount,
    required this.selectedUnit,
    required this.onAmountChanged,
    required this.onUnitChanged,
  });

  final ReminderPreset selectedPreset;
  final ValueChanged<ReminderPreset> onPresetChanged;
  final int selectedAmount;
  final ReminderUnit selectedUnit;
  final ValueChanged<int> onAmountChanged;
  final ValueChanged<ReminderUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final isCustom = selectedPreset == ReminderPreset.custom;
    final selectedLabel = _formatSelectedReminder(
      preset: selectedPreset,
      amount: selectedAmount,
      unit: selectedUnit,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cFFE6DBD2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: AppColors.cFFA48C7E,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  'When to Remind Me',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cFF8B6758,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.cFFEEE4DB),
            const SizedBox(height: 16),
            _ReminderChoiceTile(
              title: '1 day before',
              selected: selectedPreset == ReminderPreset.oneDayBefore,
              onTap: () => onPresetChanged(ReminderPreset.oneDayBefore),
            ),
            const SizedBox(height: 12),
            _ReminderChoiceTile(
              title: '6 hours before',
              selected: selectedPreset == ReminderPreset.sixHoursBefore,
              onTap: () => onPresetChanged(ReminderPreset.sixHoursBefore),
            ),
            const SizedBox(height: 12),
            _ReminderChoiceTile(
              title: 'Custom reminder',
              selected: isCustom,
              onTap: () => onPresetChanged(ReminderPreset.custom),
            ),
            const SizedBox(height: 14),
            Text(
              'Selected: $selectedLabel',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.cFF8B6758,
              ),
            ),
            if (isCustom) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.cFFEEE4DB),
              const SizedBox(height: 12),
              const Text(
                'Choose amount and unit below',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cFFA48C7E,
                ),
              ),
              const SizedBox(height: 12),
              _CustomReminderPicker(
                selectedAmount: selectedAmount,
                selectedUnit: selectedUnit,
                onAmountChanged: onAmountChanged,
                onUnitChanged: onUnitChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReminderChoiceTile extends StatelessWidget {
  const _ReminderChoiceTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? AppColors.cFFFFF8EA : AppColors.cFFFBF8F5,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.cFFDEAF5F : AppColors.cFFE6DBD2,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.cFF8B6758 : AppColors.cFFA48C7E,
                ),
              ),
            ),
            _RadioIndicator(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 3,
          color: selected ? AppColors.cFFDEAF5F : AppColors.cFFD9CEC5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.cFFDEAF5F,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _CustomReminderPicker extends StatelessWidget {
  const _CustomReminderPicker({
    required this.selectedAmount,
    required this.selectedUnit,
    required this.onAmountChanged,
    required this.onUnitChanged,
  });

  final int selectedAmount;
  final ReminderUnit selectedUnit;
  final ValueChanged<int> onAmountChanged;
  final ValueChanged<ReminderUnit> onUnitChanged;

  static final List<int> _amounts = List<int>.generate(7, (index) => index + 1);
  static const List<ReminderUnit> _units = [
    ReminderUnit.hoursBefore,
    ReminderUnit.daysBefore,
    ReminderUnit.weeksBefore,
  ];

  @override
  Widget build(BuildContext context) {
    final amountValue = _amounts.contains(selectedAmount)
        ? selectedAmount
        : _amounts.first;
    final unitValue = _units.contains(selectedUnit)
        ? selectedUnit
        : _units.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cFFA48C7E,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: amountValue,
                isExpanded: true,
                icon: const Icon(Icons.expand_more_rounded),
                decoration: _dropdownDecoration(),
                items: _amounts
                    .map(
                      (amount) => DropdownMenuItem<int>(
                        value: amount,
                        child: Text(amount.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onAmountChanged(value);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cFFA48C7E,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ReminderUnit>(
                value: unitValue,
                isExpanded: true,
                icon: const Icon(Icons.expand_more_rounded),
                decoration: _dropdownDecoration(),
                items: _units
                    .map(
                      (unit) => DropdownMenuItem<ReminderUnit>(
                        value: unit,
                        child: Text(unit.dropdownLabel),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onUnitChanged(value);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColors.cFFF8F3EC,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cFFE6DBD2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cFFE6DBD2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cFFDEAF5F, width: 1.6),
      ),
    );
  }
}

String _formatSelectedReminder({
  required ReminderPreset preset,
  required int amount,
  required ReminderUnit unit,
}) {
  switch (preset) {
    case ReminderPreset.oneDayBefore:
      return '1 day before';
    case ReminderPreset.sixHoursBefore:
      return '6 hours before';
    case ReminderPreset.custom:
      return '$amount ${unit.countLabel(amount)} before';
  }
}
