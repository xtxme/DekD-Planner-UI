import 'package:my_first_app/features/settings/data/models/profile_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDao {
  SupabaseProfileDao({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static const _table = 'profiles';

  Future<ProfileRow> getOrCreate() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('User is not authenticated');

    final List<dynamic> rows =
        await _client.from(_table).select().eq('user_id', user.id).limit(1);
    if (rows.isNotEmpty) {
      return ProfileRow.fromMap(rows.first as Map<String, dynamic>);
    }

    final created = ProfileRow(
      userId: user.id,
      displayName: user.userMetadata?['display_name'] as String?,
      bio: '',
      avatarUrl: null,
    );

    await _client.from(_table).insert(created.toUpsertMap());
    return created;
  }

  Future<void> upsert(ProfileRow row) async {
    await _client.from(_table).upsert(row.toUpsertMap(), onConflict: 'user_id');
  }
}
