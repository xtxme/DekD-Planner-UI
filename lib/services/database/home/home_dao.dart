import 'package:my_first_app/services/database/app_database.dart';
import 'package:my_first_app/services/database/home/home_task.dart';
import 'package:sqflite/sqflite.dart';

class HomeDao {
  HomeDao({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const String _table = 'home_tasks';

  Future<int> insert(HomeTask task) async {
    final db = await _database.database;
    return db.insert(_table, task.toMap());
  }

  Future<List<HomeTask>> getAll() async {
    final db = await _database.database;
    final rows = await db.query(_table, orderBy: 'due_at ASC');
    return rows.map(HomeTask.fromMap).toList();
  }

  Future<int> update(HomeTask task) async {
    final db = await _database.database;
    return db.update(
      _table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _database.database;
    await db.delete(_table);
  }
}