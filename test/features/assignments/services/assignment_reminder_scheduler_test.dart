import 'package:my_first_app/core/notifications/reminder_notification_port.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/assignments/services/assignment_reminder_scheduler.dart';
import 'package:my_first_app/features/settings/data/models/notification_preference_row.dart';
import 'package:test/test.dart';

void main() {
  group('AssignmentReminderScheduler', () {
    test('skips completed assignments and past reminder times', () async {
      final service = _FakeLocalNotificationService();
      final scheduler = AssignmentReminderScheduler(
        notificationService: service,
      );
      final now = DateTime(2026, 3, 6, 10, 0);

      final assignments = [
        AssignmentRow(
          id: 'active-future',
          title: 'Math worksheet',
          subject: 'Math',
          subjectId: 's1',
          dueAt: now.add(const Duration(days: 2)),
          notes: '',
          status: 'in_progress',
          completedAt: null,
        ),
        AssignmentRow(
          id: 'active-past-reminder',
          title: 'Chem report',
          subject: 'Chemistry',
          subjectId: 's2',
          dueAt: now.add(const Duration(hours: 3)),
          notes: '',
          status: 'in_progress',
          completedAt: null,
        ),
        AssignmentRow(
          id: 'completed-future',
          title: 'Physics',
          subject: 'Physics',
          subjectId: 's3',
          dueAt: now.add(const Duration(days: 3)),
          notes: '',
          status: 'completed',
          completedAt: now,
        ),
      ];

      final prefs = NotificationPreferenceRow(
        userId: 'u1',
        allNotificationsEnabled: true,
        reminderPreset: 'one_day_before',
        reminderAmount: 1,
        reminderUnit: 'days_before',
      );

      await scheduler.resyncAll(
        assignments: assignments,
        preferences: prefs,
        now: now,
      );

      expect(service.cancelAllCalled, isTrue);
      expect(service.scheduled.length, 1);
      expect(service.scheduled.first.payload, 'active-future');
      expect(
        service.scheduled.first.scheduledAt,
        now.add(const Duration(days: 1)),
      );
    });

    test('supports one day, six hours, and custom offsets', () async {
      final service = _FakeLocalNotificationService();
      final scheduler = AssignmentReminderScheduler(
        notificationService: service,
      );
      final now = DateTime(2026, 3, 6, 10, 0);
      final dueAt = now.add(const Duration(days: 2));

      final assignments = [
        AssignmentRow(
          id: 'a1',
          title: 'Essay',
          subject: 'English',
          subjectId: 's4',
          dueAt: dueAt,
          notes: '',
          status: 'in_progress',
          completedAt: null,
        ),
      ];

      final prefs = NotificationPreferenceRow(
        userId: 'u1',
        allNotificationsEnabled: true,
        reminderPreset: 'one_day_before,six_hours_before,custom',
        reminderAmount: 3,
        reminderUnit: 'hours_before',
      );

      await scheduler.resyncAll(
        assignments: assignments,
        preferences: prefs,
        now: now,
      );

      final scheduledTimes = service.scheduled
          .map((item) => item.scheduledAt)
          .toSet();

      expect(scheduledTimes.length, 3);
      expect(
        scheduledTimes.contains(dueAt.subtract(const Duration(days: 1))),
        isTrue,
      );
      expect(
        scheduledTimes.contains(dueAt.subtract(const Duration(hours: 6))),
        isTrue,
      );
      expect(
        scheduledTimes.contains(dueAt.subtract(const Duration(hours: 3))),
        isTrue,
      );
    });

    test('clears all reminders when notifications are disabled', () async {
      final service = _FakeLocalNotificationService();
      final scheduler = AssignmentReminderScheduler(
        notificationService: service,
      );

      final prefs = NotificationPreferenceRow(
        userId: 'u1',
        allNotificationsEnabled: false,
        reminderPreset: 'one_day_before',
        reminderAmount: 1,
        reminderUnit: 'days_before',
      );

      await scheduler.resyncAll(assignments: const [], preferences: prefs);

      expect(service.cancelAllCalled, isTrue);
      expect(service.scheduled, isEmpty);
    });
  });
}

class _FakeLocalNotificationService implements ReminderNotificationPort {
  bool cancelAllCalled = false;
  final List<_ScheduledReminder> scheduled = [];

  @override
  Future<void> cancelAllReminders() async {
    cancelAllCalled = true;
    scheduled.clear();
  }

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    scheduled.add(
      _ScheduledReminder(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }
}

class _ScheduledReminder {
  const _ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? payload;
}
