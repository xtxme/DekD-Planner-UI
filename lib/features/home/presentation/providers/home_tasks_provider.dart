import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/providers/database_provider.dart';
import 'package:my_first_app/features/home/data/local/home_dao.dart';
import 'package:my_first_app/features/home/data/models/home_task_row.dart';

final homeDaoProvider = Provider<HomeDao>(
  (ref) => HomeDao(database: ref.watch(appDatabaseProvider)),
);

final homeTasksProvider = FutureProvider<List<HomeTask>>(
  (ref) async {
    final dao = ref.watch(homeDaoProvider);
    return dao.getAll();
  },
);
