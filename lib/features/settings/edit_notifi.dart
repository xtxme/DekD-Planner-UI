import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/widgets/auth_primary_button.dart';
import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';
import 'widgets/notification_master_switch_card.dart';
import 'widgets/notification_reminder_card.dart';

class EditNotificationPage extends ConsumerStatefulWidget {
  const EditNotificationPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<EditNotificationPage> createState() =>
      _EditNotificationPageState();
}

class _EditNotificationPageState extends ConsumerState<EditNotificationPage> {
  bool _allNotificationsEnabled = true;
  ReminderPreset _selectedPreset = ReminderPreset.oneDayBefore;
  int _selectedAmount = 1;
  ReminderUnit _selectedUnit = ReminderUnit.daysBefore;

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationMasterSwitchCard(
                      enabled: _allNotificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _allNotificationsEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: _allNotificationsEnabled ? 1 : 0.48,
                      child: IgnorePointer(
                        ignoring: !_allNotificationsEnabled,
                        child: NotificationReminderCard(
                          selectedPreset: _selectedPreset,
                          onPresetChanged: (preset) {
                            setState(() {
                              _selectedPreset = preset;
                            });
                          },
                          selectedAmount: _selectedAmount,
                          selectedUnit: _selectedUnit,
                          onAmountChanged: (amount) {
                            setState(() {
                              _selectedAmount = amount;
                            });
                          },
                          onUnitChanged: (unit) {
                            setState(() {
                              _selectedUnit = unit;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthPrimaryButton(
                      label: 'Apply Settings',
                      onPressed: _allNotificationsEnabled
                          ? _onApplySettings
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.withNavBar
          ? AppNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentNavIndexProvider.notifier).state = index;
              },
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F2EE),
        border: Border(bottom: BorderSide(color: Color(0xFFE7DDD4))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF8B6758),
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              'Notification Preferences',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF8B6758),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _onApplySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings applied.')),
    );
  }
}
