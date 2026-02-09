import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/assignment_draft.dart';

final assignmentDraftProvider = StateProvider<AssignmentDraft?>(
  (ref) => AssignmentDraft(
    title: 'Algebra Worksheet 4.2',
    subject: 'Mathematics',
    dueDateTime: DateTime(2023, 10, 24, 16, 0),
    notes:
        'Complete all problems in Chapter 4 section 2. '
        'Make sure to show your work for the polynomial division problems.\n'
        'Remember to check the back of the book for odd-numbered answers.\n'
        'Upload the scan as a single PDF.',
  ),
);
