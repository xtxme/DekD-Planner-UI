import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/home/data/models/home_task_row.dart';
import 'package:my_first_app/features/home/data/remote/supabase_home_dao.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/providers.dart';

final homeDaoProvider = Provider<HomeDao>(
  (ref) => HomeDao(client: ref.watch(supabaseClientProvider)),
);

final homeTasksProvider = FutureProvider<List<HomeTask>>((ref) async {
  final dao = ref.watch(homeDaoProvider);
  return dao.getAll();
});

final canvasAssignmentRemoteDataSourceProvider =
    Provider<CanvasAssignmentRemoteDataSource>(
      (ref) => CanvasAssignmentRemoteDataSource(
        client: ref.watch(supabaseClientProvider),
      ),
    );

/// ✅ ดึงข้อมูล Canvas assignments พร้อม user info
/// ✅ Added retry logic to handle transient auth failures
final canvasAssignmentsWithUserProvider =
    FutureProvider<CanvasAssignmentsResponse>((ref) async {
      // Add a small delay to ensure JWT is fully propagated to backend
      await Future.delayed(const Duration(milliseconds: 300));

      final remoteDataSource = ref.watch(
        canvasAssignmentRemoteDataSourceProvider,
      );

      // Use retry logic to handle transient auth failures
      final response = await _fetchWithRetry(
        () => remoteDataSource.fetchAssignmentsWithUser(),
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 500),
      );

      final subjects = await ref.watch(subjectListProvider.future);
      final resolvedAssignments = _resolveAssignmentSubjects(
        response.assignments,
        subjects,
      );

      return CanvasAssignmentsResponse(
        user: response.user,
        assignments: resolvedAssignments,
      );
    });

/// Helper function to retry operations with exponential backoff
Future<T> _fetchWithRetry<T>(
  Future<T> Function() operation, {
  required int maxAttempts,
  required Duration initialDelay,
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (true) {
    attempt++;

    try {
      return await operation();
    } catch (error) {
      // Only retry on auth-related errors
      final isAuthError =
          error is CanvasSessionExpiredException ||
          error.toString().toLowerCase().contains('invalid jwt') ||
          error.toString().toLowerCase().contains('unauthorized');

      if (attempt >= maxAttempts || !isAuthError) {
        rethrow;
      }

      debugPrint(
        'RETRY_DEBUG: Auth error on attempt $attempt/$maxAttempts, retrying in ${delay.inMilliseconds}ms...',
      );

      await Future.delayed(delay);

      // Exponential backoff
      delay = Duration(
        milliseconds: (delay.inMilliseconds * 2).clamp(
          initialDelay.inMilliseconds,
          5000, // Max 5 seconds
        ),
      );
    }
  }
}

/// ✅ Provider เดิมสำหรับ backward compatibility
/// ใช้ canvasAssignmentsWithUserProvider แทน
@Deprecated('Use canvasAssignmentsWithUserProvider instead')
final homeCanvasAssignmentsProvider = FutureProvider<List<CanvasAssignment>>((
  ref,
) async {
  final response = await ref.watch(canvasAssignmentsWithUserProvider.future);
  return response.assignments;
});

class HomeAssignmentSections {
  const HomeAssignmentSections({required this.today, required this.tomorrow});

  final List<CanvasAssignment> today;
  final List<CanvasAssignment> tomorrow;
}

/// ✅ Provider ใหม่ที่ใช้ CanvasAssignmentsResponse โดยตรง
final homeCanvasAssignmentSectionsProvider =
    FutureProvider<HomeAssignmentSections>((ref) async {
      final response = await ref.watch(
        canvasAssignmentsWithUserProvider.future,
      );
      final assignments = response.assignments
          .where((assignment) => !assignment.isCompleted)
          .toList(growable: false);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      final dayAfterTomorrowStart = todayStart.add(const Duration(days: 2));

      final today = assignments.where((assignment) {
        final dueAt = assignment.dueAt;
        if (dueAt == null) return false;
        return !dueAt.isBefore(todayStart) && dueAt.isBefore(tomorrowStart);
      }).toList();

      final tomorrow = assignments.where((assignment) {
        final dueAt = assignment.dueAt;
        if (dueAt == null) return false;
        return !dueAt.isBefore(tomorrowStart) &&
            dueAt.isBefore(dayAfterTomorrowStart);
      }).toList();

      return HomeAssignmentSections(today: today, tomorrow: tomorrow);
    });

/// ✅ Provider สำหรับแสดง user info จาก Canvas response
final canvasUserProvider = Provider<CanvasUserResponse>((ref) {
  final response = ref.watch(canvasAssignmentsWithUserProvider).value;
  if (response == null) {
    return const CanvasUserResponse(id: '', email: '');
  }
  return response.user;
});

List<CanvasAssignment> _resolveAssignmentSubjects(
  List<CanvasAssignment> assignments,
  List<SubjectRow> subjects,
) {
  final subjectNameByCourseId = <int, String>{};

  for (final subject in subjects) {
    final courseId = _extractCanvasCourseId(subject.description);
    if (courseId == null) continue;

    final name = subject.name.trim();
    if (name.isEmpty) continue;

    subjectNameByCourseId.putIfAbsent(courseId, () => name);
  }

  return assignments
      .map((assignment) {
        final courseId = assignment.courseId;
        if (courseId == null) return assignment;

        final subjectName = subjectNameByCourseId[courseId];
        if (subjectName == null || subjectName.isEmpty) return assignment;

        return CanvasAssignment(
          id: assignment.id,
          name: assignment.name,
          dueAt: assignment.dueAt,
          courseId: assignment.courseId,
          courseName: subjectName,
          description: assignment.description,
          isCompleted: assignment.isCompleted,
          submissionState: assignment.submissionState,
        );
      })
      .toList(growable: false);
}

int? _extractCanvasCourseId(String description) {
  final match = RegExp(
    r'course_id:\s*(\d+)',
    caseSensitive: false,
  ).firstMatch(description);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

/// ✅ Provider สำหรับ Canvas Assignment Details (มากขึ้น)
/// Fetch เมื่อ user กดดู assignment details
final canvasAssignmentDetailsProvider =
    FutureProvider.family<CanvasAssignmentDetails, AssignmentDetailsParams>((
      ref,
      params,
    ) async {
      return ref
          .read(canvasAssignmentRemoteDataSourceProvider)
          .fetchAssignmentDetails(
            assignmentId: params.assignmentId,
            courseId: params.courseId,
          );
    });

/// ✅ Parameters สำหรับเรียก assignment details
class AssignmentDetailsParams {
  const AssignmentDetailsParams({
    required this.assignmentId,
    required this.courseId,
  });

  final int assignmentId;
  final int courseId;
}
