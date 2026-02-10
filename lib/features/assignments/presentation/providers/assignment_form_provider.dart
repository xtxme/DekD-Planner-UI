//จุดเชื่อมระหว่าง Riverpod ↔ Database ↔ Feature (Assignments)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/providers/database_provider.dart';
import 'package:my_first_app/features/assignments/data/local/assignment_dao.dart';
import 'package:my_first_app/features/assignments/models/assignment_draft.dart';

final assignmentDaoProvider = Provider<AssignmentDao>(
  (ref) => SqliteAssignmentDao(database: ref.watch(appDatabaseProvider)),
);

final assignmentFormProvider = StateProvider<AssignmentDraft?>(
  (ref) => null,
);
