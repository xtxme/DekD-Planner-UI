import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/home/data/local/home_dao.dart';
import 'package:my_first_app/features/home/data/models/home_task_row.dart';

final homeDaoProvider = Provider<HomeDao>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);

final homeTasksProvider = FutureProvider<List<HomeTask>>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);
