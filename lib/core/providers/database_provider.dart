import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);

// Backward-friendly alias while naming is still being finalized.
final databaseProvider = appDatabaseProvider;
