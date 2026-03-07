abstract class ReminderNotificationPort {
  Future<void> cancelAllReminders();

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  });
}
