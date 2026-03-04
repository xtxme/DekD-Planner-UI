import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/home/data/models/home_task_row.dart';
import 'package:my_first_app/features/home/data/remote/supabase_home_dao.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';

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
final canvasAssignmentsWithUserProvider =
    FutureProvider<CanvasAssignmentsResponse>((ref) async {
      return ref
          .watch(canvasAssignmentRemoteDataSourceProvider)
          .fetchAssignmentsWithUser();
    });

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
      final assignments = response.assignments;

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
