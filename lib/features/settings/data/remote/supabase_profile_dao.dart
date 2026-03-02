import 'package:my_first_app/features/settings/data/models/profile_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:my_first_app/features/settings/data/models/profile_row.dart';
import 'dart:io'; //นำเข้า Library มาตรฐาน
import 'package:path/path.dart' as path; //จัดการชื่อและเส้นทาง (Path)
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDao {
  SupabaseProfileDao({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static const _table = 'profiles';
  static const _avatarBucket =
      'avatars'; //ตัวแปรคงที่เพื่อใช้แทนชื่อของ Bucket ใน Supabase ครับ

  Future<ProfileRow> getOrCreate() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('User is not authenticated');

    final List<dynamic> rows = await _client
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .limit(1);
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

  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final extension = path
        .extension(file.path)
        .toLowerCase(); //การหานามสกุลไฟล์ดึงค่าออกมาให้ เปลี่ยนตัวอักษรให้เป็น ตัวพิมพ์เล็กทั้งหมด
    final filePath = '$userId/avatar$extension'; //การสร้างเส้นทางจัดเก็บ

    await _client.storage
        .from(_avatarBucket)
        .upload(
          filePath, //ที่อยู่ปลายทางบน Cloud
          file, //ตัวไฟล์จริงๆ
          fileOptions: const FileOptions(
            upsert:
                true, //หากมีไฟล์ชื่อเดิมอยู่แล้ว มันจะทำการเขียนทับ (Overwrite)
            cacheControl: '3600',
          ),
        );
    return _client.storage.from(_avatarBucket).getPublicUrl(filePath);
  }
}
