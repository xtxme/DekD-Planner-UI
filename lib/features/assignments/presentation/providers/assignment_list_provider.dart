import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/assignments/models/assignments_feed_item.dart';
import 'package:my_first_app/features/home/presentation/providers/home_tasks_provider.dart';
import 'package:my_first_app/features/subjects/providers.dart';

import 'assignments_ui_mapper.dart';
import 'assignment_form_provider.dart';

final assignmentListProvider = FutureProvider<List<AssignmentRow>>((ref) async {
  final dao = ref.watch(assignmentDaoProvider);
  return dao.getAll();
});

final assignmentsUiMapperProvider = Provider<AssignmentsUiMapper>((ref) {
  return const AssignmentsUiMapper();
});

final selectedAssignmentSubjectProvider = StateProvider<String?>((ref) => null);

final assignmentFilterSubjectsProvider = FutureProvider<List<String>>((
  ref,
) async {
  final localSubjectsFuture = ref.watch(subjectListProvider.future);
  final canvasResponseFuture = ref.watch(
    canvasAssignmentsWithUserProvider.future,
  );

  final localSubjects = await localSubjectsFuture;
  final canvasResponse = await canvasResponseFuture;

  final subjectNames = <String>{
    ...localSubjects
        .map((row) => row.name.trim())
        .where((name) => name.isNotEmpty),
    ...canvasResponse.assignments
        .map((assignment) => assignment.courseName.trim())
        .where((name) => name.isNotEmpty),
  }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return subjectNames;
});

final assignmentsFeedSectionsProvider = FutureProvider<AssignmentsFeedSections>(
  (ref) async {
    final mapper = ref.watch(assignmentsUiMapperProvider);
    final selectedSubject = ref.watch(selectedAssignmentSubjectProvider);

    final localRows = await ref.watch(assignmentListProvider.future);
    final canvasResponse = await ref.watch(
      canvasAssignmentsWithUserProvider.future,
    );

    final localItems = localRows
        .where((row) => row.status != 'completed')
        .map(mapper.fromLocal);

    final canvasItems = canvasResponse.assignments
        .map(mapper.fromCanvas)
        .whereType<AssignmentsFeedItem>();

    final merged = [...localItems, ...canvasItems].toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final filtered = selectedSubject == null || selectedSubject.trim().isEmpty
        ? merged
        : merged
              .where((item) {
                return item.subject.trim().toLowerCase() ==
                    selectedSubject.trim().toLowerCase();
              })
              .toList(growable: false);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final daysUntilWeekEnd = DateTime.sunday - todayStart.weekday;
    final weekEndStart = todayStart.add(Duration(days: daysUntilWeekEnd + 1));

    final today = filtered
        .where((item) {
          return item.dueAt.isBefore(tomorrowStart);
        })
        .toList(growable: false);

    final thisWeek = filtered
        .where((item) {
          return !item.dueAt.isBefore(tomorrowStart) &&
              item.dueAt.isBefore(weekEndStart);
        })
        .toList(growable: false);

    final later = filtered
        .where((item) {
          return !item.dueAt.isBefore(weekEndStart);
        })
        .toList(growable: false);

    return AssignmentsFeedSections(
      today: today,
      thisWeek: thisWeek,
      later: later,
    );
  },
);
