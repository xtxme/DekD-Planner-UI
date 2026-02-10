import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AssignmentDao {
  Future<String> insert(AssignmentRow row);
  Future<List<AssignmentRow>> getAll();
  Future<void> update(AssignmentRow row);
  Future<void> delete(String id);
}

class SupabaseAssignmentDao implements AssignmentDao {
  SupabaseAssignmentDao({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  static const String _table = 'assignments';

  @override
  Future<String> insert(AssignmentRow row) async {
    final userId = _requireUserId();

    final inserted = await _client
        .from(_table)
        .insert(row.toInsertMap(userId: userId))
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  @override
  Future<List<AssignmentRow>> getAll() async {
    final userId = _requireUserId();

    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('due_at', ascending: true);

    return (rows as List<dynamic>)
        .map((row) => AssignmentRow.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> update(AssignmentRow row) async {
    final id = row.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('AssignmentRow.id is required for update');
    }

    final userId = _requireUserId();

    await _client
        .from(_table)
        .update(row.toUpdateMap())
        .eq('id', id)
        .eq('user_id', userId);
  }

  @override
  Future<void> delete(String id) async {
    final userId = _requireUserId();

    await _client.from(_table).delete().eq('id', id).eq('user_id', userId);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User is not authenticated');
    }
    return userId;
  }
}
