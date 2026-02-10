//จุดเชื่อมระหว่าง Riverpod ↔ Database ↔ Feature (Assignments)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/assignments/data/remote/supabase_assignment_dao.dart';
import 'package:my_first_app/features/assignments/models/assignment_draft.dart';

final assignmentDaoProvider = Provider<AssignmentDao>(
  (ref) => SupabaseAssignmentDao(client: ref.watch(supabaseClientProvider)),
);

final assignmentFormProvider = StateProvider<AssignmentDraft?>(
  (ref) => null,
);
