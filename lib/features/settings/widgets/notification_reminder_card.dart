import 'package:flutter/material.dart';

enum ReminderPreset { oneDayBefore, sixHoursBefore, custom }

enum ReminderUnit { hoursBefore, daysBefore, weeksBefore }

extension ReminderUnitLabel on ReminderUnit {
  String get label {
    switch (this) {
      case ReminderUnit.hoursBefore:
        return 'Hours Before';
      case ReminderUnit.daysBefore:
        return 'Days Before';
      case ReminderUnit.weeksBefore:
        return 'Weeks Before';
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
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
                  color: Color(0xFFA68D7E),
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  'When to Remind Me',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7E5E4E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE8DDD3)),
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
              title: 'Custom...',
              selected: isCustom,
              onTap: () => onPresetChanged(ReminderPreset.custom),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE8DDD3)),
            const SizedBox(height: 14),
            Opacity(
              opacity: isCustom ? 1 : 0.45,
              child: IgnorePointer(
                ignoring: !isCustom,
                child: _CustomReminderPicker(
                  selectedAmount: selectedAmount,
                  selectedUnit: selectedUnit,
                  onAmountChanged: onAmountChanged,
                  onUnitChanged: onUnitChanged,
                ),
              ),
            ),
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
          color: selected ? const Color(0xFFFFFCF7) : const Color(0xFFF6F4F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFDEAF5F) : const Color(0xFFDCD0C5),
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
                  color: selected
                      ? const Color(0xFF7E5E4E)
                      : const Color(0xFF8D7668),
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
          color: selected ? const Color(0xFFDEAF5F) : const Color(0xFFD9CEC2),
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFFDEAF5F),
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

  static const List<int> _amounts = [1, 2, 3];
  static const List<ReminderUnit> _units = [
    ReminderUnit.hoursBefore,
    ReminderUnit.daysBefore,
    ReminderUnit.weeksBefore,
  ];

  @override
  Widget build(BuildContext context) {
    var amountIndex = _amounts.indexOf(selectedAmount);
    if (amountIndex < 0) {
      amountIndex = 0;
    }

    var unitIndex = _units.indexOf(selectedUnit);
    if (unitIndex < 0) {
      unitIndex = 0;
    }

    final hasTop = amountIndex > 0 || unitIndex > 0;
    final hasBottom =
        amountIndex < _amounts.length - 1 || unitIndex < _units.length - 1;

    final topAmount = amountIndex > 0
        ? _amounts[amountIndex - 1].toString()
        : '';
    final topUnit = unitIndex > 0 ? _units[unitIndex - 1].label : '';
    final bottomAmount = amountIndex < _amounts.length - 1
        ? _amounts[amountIndex + 1].toString()
        : '';
    final bottomUnit = unitIndex < _units.length - 1
        ? _units[unitIndex + 1].label
        : '';

    return Column(
      children: [
        _PickerRow(
          amountText: topAmount,
          unitText: topUnit,
          muted: true,
          onTap: hasTop
              ? () {
                  if (amountIndex > 0) {
                    onAmountChanged(_amounts[amountIndex - 1]);
                  }
                  if (unitIndex > 0) {
                    onUnitChanged(_units[unitIndex - 1]);
                  }
                }
              : null,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedAmount.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7E5E4E),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  selectedUnit.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7E5E4E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _PickerRow(
          amountText: bottomAmount,
          unitText: bottomUnit,
          muted: true,
          onTap: hasBottom
              ? () {
                  if (amountIndex < _amounts.length - 1) {
                    onAmountChanged(_amounts[amountIndex + 1]);
                  }
                  if (unitIndex < _units.length - 1) {
                    onUnitChanged(_units[unitIndex + 1]);
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.amountText,
    required this.unitText,
    required this.muted,
    this.onTap,
  });

  final String amountText;
  final String unitText;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = muted ? const Color(0xFFDDD2C7) : const Color(0xFF7E5E4E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            Expanded(
              child: Text(
                amountText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                unitText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
