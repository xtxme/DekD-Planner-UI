//การใช้ Riverpod เพื่อจัดการ instance ของ database (AppDatabase)

import 'package:flutter_riverpod/flutter_riverpod.dart'; //ใช้สร้าง Provider
import 'package:my_first_app/core/database/app_database.dart'; //ไฟล์ที่ประกาศ class AppDatabase

final appDatabaseProvider = Provider<AppDatabase>( //Riverpod Provider แบบอ่านอย่างเดียว
  (ref) => AppDatabase.instance, //ทุกครั้งที่มีคน read provider นี้จะได้ AppDatabase.instance ตัวเดียวกันเสมอ
);

// Backward-friendly alias while naming is still being finalized.
final databaseProvider = appDatabaseProvider;
