import 'dart:math';

import 'package:intl/intl.dart';
import 'package:my_first_app/core/notifications/reminder_notification_port.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/settings/data/models/notification_preference_row.dart';

class AssignmentReminderScheduler {
  AssignmentReminderScheduler({
    required ReminderNotificationPort notificationService,
  }) : _notificationService = notificationService;

  final ReminderNotificationPort _notificationService;

  Future<void> resyncAll({
    required List<AssignmentRow> assignments,
    required NotificationPreferenceRow preferences,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();

    await _notificationService.cancelAllReminders();

    if (!preferences.allNotificationsEnabled) {
      return;
    }

    final offsets = _resolveOffsets(preferences).toList(growable: false);
    if (offsets.isEmpty) {
      return;
    }

    for (final assignment in assignments) {
      if (assignment.status.toLowerCase() == 'completed') {
        continue;
      }

      final assignmentId = assignment.id;
      if (assignmentId == null || assignmentId.isEmpty) {
        continue;
      }

      for (final offset in offsets) {
        final reminderTime = assignment.dueAt.subtract(offset.duration);
        if (!reminderTime.isAfter(currentTime)) {
          continue;
        }

        await _notificationService.scheduleReminder(
          id: _notificationId(
            assignmentId: assignmentId,
            offsetKey: offset.key,
          ),
          title: 'Upcoming deadline: ${assignment.title}',
          body:
              '${assignment.subject} • Due ${DateFormat('EEE, MMM d, h:mm a').format(assignment.dueAt)}',
          scheduledAt: reminderTime,
          payload: assignmentId,
        );
      }
    }
  }

  List<_ReminderOffset> _resolveOffsets(NotificationPreferenceRow preferences) {
    final tokens = preferences.reminderPresetTokens;
    final offsets = <_ReminderOffset>[];

    if (tokens.contains('one_day_before')) {
      offsets.add(
        const _ReminderOffset(
          key: 'one_day_before',
          duration: Duration(days: 1),
        ),
      );
    }
    if (tokens.contains('six_hours_before')) {
      offsets.add(
        const _ReminderOffset(
          key: 'six_hours_before',
          duration: Duration(hours: 6),
        ),
      );
    }
    if (tokens.contains('custom')) {
      final customDuration = _buildCustomDuration(
        amount: preferences.reminderAmount,
        unit: preferences.reminderUnit,
      );
      if (customDuration.inSeconds > 0) {
        offsets.add(_ReminderOffset(key: 'custom', duration: customDuration));
      }
    }

    if (offsets.isEmpty) {
      offsets.add(
        const _ReminderOffset(
          key: 'one_day_before',
          duration: Duration(days: 1),
        ),
      );
    }

    final deduped = <String, _ReminderOffset>{
      for (final offset in offsets) offset.key: offset,
    };

    return deduped.values.toList(growable: false);
  }

  Duration _buildCustomDuration({required int amount, required String unit}) {
    final safeAmount = max(1, amount);
    switch (unit) {
      case 'hours_before':
        return Duration(hours: safeAmount);
      case 'weeks_before':
        return Duration(days: safeAmount * 7);
      case 'days_before':
      default:
        return Duration(days: safeAmount);
    }
  }

  int _notificationId({
    required String assignmentId,
    required String offsetKey,
  }) {
    final input = '$assignmentId::$offsetKey';
    var hash = 0;
    for (final codeUnit in input.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}

class _ReminderOffset {
  const _ReminderOffset({required this.key, required this.duration});

  final String key;
  final Duration duration;
}
