import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/assignments/presentation/providers/assignment_form_provider.dart';

class CalendarRange {
  const CalendarRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

final calendarAssignmentsProvider =
    FutureProvider.family<List<AssignmentRow>, CalendarRange>(
  (ref, range) async {
    final dao = ref.watch(assignmentDaoProvider);
    return dao.getAll(from: range.start, to: range.end);
  },
);
