import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/data/remote/supabase_subject_dao.dart';

final subjectDaoProvider = Provider<SubjectDao>(
  (ref) => SupabaseSubjectDao(client: ref.watch(supabaseClientProvider)),
);

final subjectListProvider = FutureProvider<List<SubjectRow>>(
  (ref) async => ref.watch(subjectDaoProvider).getAll(),
);
