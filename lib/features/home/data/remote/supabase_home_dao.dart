import 'package:my_first_app/features/home/data/models/home_task_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeDao {
  HomeDao({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  static const String _table = 'home_tasks';

  Future<String> insert(HomeTask task) async {
    final userId = _requireUserId();
    final inserted = await _client
        .from(_table)
        .insert(task.toInsertMap(userId: userId))
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  Future<List<HomeTask>> getAll() async {
    final userId = _requireUserId();
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('due_at', ascending: true);

    return (rows as List<dynamic>)
        .map((row) => HomeTask.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> update(HomeTask task) async {
    final id = task.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('HomeTask.id is required for update');
    }

    final userId = _requireUserId();

    await _client
        .from(_table)
        .update(task.toUpdateMap())
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> delete(String id) async {
    final userId = _requireUserId();

    await _client.from(_table).delete().eq('id', id).eq('user_id', userId);
  }

  Future<void> clear() async {
    final userId = _requireUserId();
    await _client.from(_table).delete().eq('user_id', userId);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User is not authenticated');
    }
    return userId;
  }
}
