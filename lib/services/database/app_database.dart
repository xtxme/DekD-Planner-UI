import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'dekd_planner.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    final db = _db;
    if (db != null) return db;

    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    final basePath = await getDatabasesPath();
    final path = p.join(basePath, _dbName);
    print('DB PATH: $path');

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        for (final statement in _createStatementsV1) {
          await db.execute(statement);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // TODO: add migration steps when bumping _dbVersion.
      },
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) return;
    await db.close();
    _db = null;
  }
}

const List<String> _createStatementsV1 = <String>[
  '''
  CREATE TABLE home_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject TEXT NOT NULL,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    due_at INTEGER NOT NULL,
    tag_bg INTEGER NOT NULL,
    tag_color INTEGER NOT NULL,
    due_bg INTEGER NOT NULL,
    due_color INTEGER NOT NULL,
    show_due_pill INTEGER NOT NULL
  );
  ''',
  '''
  CREATE TABLE auth_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    password_salt TEXT NOT NULL,
    created_at INTEGER NOT NULL
    last_login_at INTEGER
  );
  ''',
  '''
  CREATE TABLE auth_reset_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    password_salt TEXT NOT NULL,
    created_at INTEGER NOT NULL
    last_login_at INTEGER
  );
  ''',
];
