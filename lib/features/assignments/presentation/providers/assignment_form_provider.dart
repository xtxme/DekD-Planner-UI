import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/assignments/data/local/assignment_dao.dart';
import 'package:my_first_app/features/assignments/models/assignment_draft.dart';

final assignmentDaoProvider = Provider<AssignmentDao>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);

final assignmentFormProvider = StateProvider<AssignmentDraft?>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);
