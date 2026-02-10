import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/home/data/models/home_task_row.dart';
import 'package:my_first_app/features/home/data/remote/supabase_home_dao.dart';

final homeDaoProvider = Provider<HomeDao>(
  (ref) => HomeDao(client: ref.watch(supabaseClientProvider)),
);

final homeTasksProvider = FutureProvider<List<HomeTask>>(
  (ref) async {
    final dao = ref.watch(homeDaoProvider);
    return dao.getAll();
  },
);
