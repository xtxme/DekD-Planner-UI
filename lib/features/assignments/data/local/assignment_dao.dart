//เขียนคำสั่ง SQL query / insert / update / delete
//ตัวกลางคุยกับ Database

import 'package:my_first_app/core/database/app_database.dart'; //ตัวจัดการ SQLite
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';

abstract class AssignmentDao {
  Future<int> insert(AssignmentRow row); //เพิ่ม Assignment 1 ตัวลง DB
  Future<List<AssignmentRow>> getAll(); //ดึง Assignment ทั้งหมดจาก DB
  Future<int> update(AssignmentRow row); //แก้ไข Assignment เดิม
  Future<int> delete(int id); //ลบ Assignment ตาม id
}

class SqliteAssignmentDao implements AssignmentDao {
  SqliteAssignmentDao({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<int> insert(AssignmentRow row) async {
    // TODO(Step 5): implement SQLite insert.
    throw UnimplementedError('TODO Step 5');
  }

  @override
  Future<List<AssignmentRow>> getAll() async {
    // Keep reference for future use to avoid lint.
    await _database.database;
    // TODO(Step 5): implement SQLite query.
    throw UnimplementedError('TODO Step 5');
  }

  @override
  Future<int> update(AssignmentRow row) async {
    // TODO(Step 5): implement SQLite update.
    throw UnimplementedError('TODO Step 5');
  }

  @override
  Future<int> delete(int id) {
    // TODO(Step 5): implement SQLite delete.
    throw UnimplementedError('TODO Step 5');
  }
}
