import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/assignments/presentation/providers/assignment_reminder_provider.dart';
import 'package:my_first_app/features/settings/data/models/notification_preference_row.dart';
import 'package:my_first_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../auth/widgets/auth_primary_button.dart';
import '../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
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
  final Set<ReminderPreset> _selectedPresets = {ReminderPreset.oneDayBefore};
  int _selectedAmount = 1;
  ReminderUnit _selectedUnit = ReminderUnit.daysBefore;
  bool _didSeedInitialValues = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _seedFromSavedPreferences();
  }

  Future<void> _seedFromSavedPreferences() async {
    try {
      final row = await ref.read(notificationPreferencesProvider.future);
      if (!mounted || _didSeedInitialValues) {
        return;
      }

      final tokens = row.reminderPresetTokens;
      final presets = <ReminderPreset>{
        if (tokens.contains('one_day_before')) ReminderPreset.oneDayBefore,
        if (tokens.contains('six_hours_before')) ReminderPreset.sixHoursBefore,
        if (tokens.contains('custom')) ReminderPreset.custom,
      };

      setState(() {
        _allNotificationsEnabled = row.allNotificationsEnabled;
        _selectedPresets
          ..clear()
          ..addAll(
            presets.isEmpty ? const {ReminderPreset.oneDayBefore} : presets,
          );
        _selectedAmount = row.reminderAmount;
        _selectedUnit = _unitFromStorage(row.reminderUnit);
        _didSeedInitialValues = true;
      });
    } catch (_) {
      if (!mounted || _didSeedInitialValues) {
        return;
      }

      setState(() {
        _didSeedInitialValues = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
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
                          selectedPresets: _selectedPresets,
                          onPresetToggled: (preset) {
                            setState(() {
                              if (_selectedPresets.contains(preset)) {
                                _selectedPresets.remove(preset);
                              } else {
                                _selectedPresets.add(preset);
                              }
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
                      label: _isApplying ? 'Applying...' : 'Apply Settings',
                      onPressed: _isApplying ? null : _onApplySettings,
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
        color: AppColors.cFFF7F2EE,
        border: Border(bottom: BorderSide(color: AppColors.cFFE7DDD4)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.cFF8B6758,
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
                color: AppColors.cFF8B6758,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Future<void> _onApplySettings() async {
    if (_isApplying) {
      return;
    }

    setState(() {
      _isApplying = true;
    });

    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId == null) {
        throw StateError('User is not authenticated');
      }

      final row = NotificationPreferenceRow(
        userId: userId,
        allNotificationsEnabled: _allNotificationsEnabled,
        reminderPreset: _serializePresets(_selectedPresets),
        reminderAmount: _selectedAmount,
        reminderUnit: _unitToStorage(_selectedUnit),
      );

      await ref.read(notificationPreferencesDaoProvider).upsert(row);
      ref.invalidate(notificationPreferencesProvider);
      await ref
          .read(assignmentReminderSyncServiceProvider)
          .resyncIfAuthenticated();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings applied.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply notification settings.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  ReminderUnit _unitFromStorage(String value) {
    switch (value) {
      case 'hours_before':
        return ReminderUnit.hoursBefore;
      case 'weeks_before':
        return ReminderUnit.weeksBefore;
      case 'days_before':
      default:
        return ReminderUnit.daysBefore;
    }
  }

  String _unitToStorage(ReminderUnit unit) {
    switch (unit) {
      case ReminderUnit.hoursBefore:
        return 'hours_before';
      case ReminderUnit.daysBefore:
        return 'days_before';
      case ReminderUnit.weeksBefore:
        return 'weeks_before';
    }
  }

  String _serializePresets(Set<ReminderPreset> presets) {
    final values = <String>[];
    if (presets.contains(ReminderPreset.oneDayBefore)) {
      values.add('one_day_before');
    }
    if (presets.contains(ReminderPreset.sixHoursBefore)) {
      values.add('six_hours_before');
    }
    if (presets.contains(ReminderPreset.custom)) {
      values.add('custom');
    }
    if (values.isEmpty) {
      values.add('one_day_before');
    }
    return values.join(',');
  }
}
