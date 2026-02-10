class NotificationPreferenceRow {
  const NotificationPreferenceRow({
    required this.userId,
    required this.allNotificationsEnabled,
    required this.reminderPreset,
    required this.reminderAmount,
    required this.reminderUnit,
  });

  final String userId;
  final bool allNotificationsEnabled;
  final String reminderPreset;
  final int reminderAmount;
  final String reminderUnit;

  Map<String, dynamic> toUpsertMap() => {
    'user_id': userId,
    'all_notifications_enabled': allNotificationsEnabled,
    'reminder_preset': reminderPreset,
    'reminder_amount': reminderAmount,
    'reminder_unit': reminderUnit,
  };
  
  factory NotificationPreferenceRow.fromMap(Map<String, dynamic> map) => 
    NotificationPreferenceRow(
      userId: map['user_id'] as String, 
      allNotificationsEnabled: map['all_notifications_enabled'] as bool? ?? true, 
      reminderPreset: map['reminder_preset'] as String? ?? 'one_day_before', 
      reminderAmount: map['reminder_amount'] as int? ?? 1,
      reminderUnit: map['reminder_unit'] as String? ?? 'days_before',
    );
}
