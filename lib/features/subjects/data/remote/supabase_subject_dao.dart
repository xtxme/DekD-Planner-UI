import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SubjectDao {
  Future<String> insert(SubjectRow row);
  Future<List<SubjectRow>> getAll({bool includeArchived = false});
  Future<void> update(SubjectRow row);
  Future<void> delete(String id);
  Future<SubjectRow?> findByName(String name);
}

class SupabaseSubjectDao implements SubjectDao {
  SupabaseSubjectDao({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static const String _table = 'subjects';

  @override
  Future<String> insert(SubjectRow row) async {
    final userId = _requireUserId();
    final inserted = await _client
        .from(_table)
        .insert(row.toInsertMap(userId: userId))
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  @override
  Future<List<SubjectRow>> getAll({bool includeArchived = false}) async {
    final userId = _requireUserId();

    var query = _client.from(_table).select().eq('user_id', userId);
    if (!includeArchived) {
      query = query.eq('is_archived', false);
    }

    final rows = await query.order('name', ascending: true);
    return (rows as List<dynamic>)
        .map((e) => SubjectRow.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> update(SubjectRow row) async {
    final id = row.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('SubjectRow.id is required for update');
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

  @override
  Future<SubjectRow?> findByName(String name) async {
    final userId = _requireUserId();
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('name', name)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return SubjectRow.fromMap(rows.first as Map<String, dynamic>);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('User is not authenticated');
    return userId;
  }
}