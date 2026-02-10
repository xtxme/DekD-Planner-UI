import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';

import 'assignment_form_provider.dart';

final assignmentListProvider = FutureProvider<List<AssignmentRow>>(
  (ref) {
    ref.watch(assignmentDaoProvider);
    throw UnimplementedError('TODO Step 4');
  },
);
