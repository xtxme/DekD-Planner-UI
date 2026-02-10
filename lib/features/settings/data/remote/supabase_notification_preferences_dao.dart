import 'package:my_first_app/features/settings/data/models/notification_preference_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationPreferencesDao {
  SupabaseNotificationPreferencesDao({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;
  static const String _table = 'user_notification_preferences';

  Future<NotificationPreferenceRow> getOrCreate() async {
    final userId = _requireUserId();

    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .limit(1);

    if ((rows as List).isNotEmpty) {
      return NotificationPreferenceRow.fromMap(
        rows.first as Map<String, dynamic>,
      );
    }

    final created = NotificationPreferenceRow(
      userId: userId,
      allNotificationsEnabled: true,
      reminderPreset: 'one_day_before',
      reminderAmount: 1,
      reminderUnit: 'days_before',
    );

    await _client.from(_table).insert(created.toUpsertMap());
    return created;
  }

  Future<void> upsert(NotificationPreferenceRow row) async {
    await _client.from(_table).upsert(row.toUpsertMap(), onConflict: 'user_id');
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User is not authenticated');
    }
    return userId;
  }
}
