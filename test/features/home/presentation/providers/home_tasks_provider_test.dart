import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/auth/domain/models/auth_user.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';
import 'package:my_first_app/features/home/presentation/providers/home_tasks_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

class _FakeCanvasAssignmentRemoteDataSource
    extends CanvasAssignmentRemoteDataSource {
  _FakeCanvasAssignmentRemoteDataSource(this._assignments)
    : super(client: SupabaseClient('https://example.com', 'anon-key'));

  final List<CanvasAssignment> _assignments;

  @override
  Future<List<CanvasAssignment>> fetchAssignments() async => _assignments;
}

void main() {
  test(
    'homeCanvasAssignmentsProvider does not treat a transient null auth provider as an expired session',
    () async {
      final assignment = CanvasAssignment(
        id: 1,
        name: 'Essay Draft',
        courseName: 'English',
        dueAt: DateTime(2026, 3, 4, 9),
        courseId: 101,
        description: 'Draft the first essay section.',
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            (ref) async => const AuthUser(
              uid: 'user-1',
              email: 'student@example.com',
            ),
          ),
          canvasAssignmentRemoteDataSourceProvider.overrideWithValue(
            _FakeCanvasAssignmentRemoteDataSource([assignment]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(homeCanvasAssignmentsProvider.future);

      expect(result, [assignment]);
    },
  );
}
