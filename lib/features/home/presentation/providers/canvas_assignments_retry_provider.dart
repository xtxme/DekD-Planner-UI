import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';
import 'package:my_first_app/core/retry/retry_with_backoff.dart';

final canvasAssignmentRemoteDataSourceProvider =
    Provider<CanvasAssignmentRemoteDataSource>(
      (ref) => CanvasAssignmentRemoteDataSource(
        client: ref.watch(supabaseClientProvider),
      ),
    );

/// ✅ Provider that fetches Canvas assignments with automatic retry on auth failures
/// This provider will retry up to 3 times with exponential backoff if it encounters
/// auth-related errors (401, Invalid JWT, etc.)
final canvasAssignmentsWithRetryProvider =
    FutureProvider<CanvasAssignmentsResponse>((ref) async {
      final remoteDataSource = ref.watch(
        canvasAssignmentRemoteDataSourceProvider,
      );

      // Use the retry extension for resilience
      return await remoteDataSource.fetchAssignmentsWithUserRetry(
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 500),
      );
    });
