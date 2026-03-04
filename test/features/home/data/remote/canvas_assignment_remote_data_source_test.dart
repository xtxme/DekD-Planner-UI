import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionException, FunctionResponse, SupabaseClient;

class _TestCanvasAssignmentRemoteDataSource
    extends CanvasAssignmentRemoteDataSource {
  _TestCanvasAssignmentRemoteDataSource({
    this.response,
    this.error,
  }) : super(client: SupabaseClient('https://example.com', 'anon-key'));

  final FunctionResponse? response;
  final Object? error;

  @override
  Future<void> requireActiveSession() async {}

  @override
  Future<FunctionResponse> invokeAssignmentsProxy() async {
    if (error != null) {
      throw error!;
    }

    return response!;
  }
}

void main() {
  test('maps 403 session_not_found response to CanvasSessionExpiredException', () async {
    final dataSource = _TestCanvasAssignmentRemoteDataSource(
      response: FunctionResponse(
        status: 403,
        data: {
          'code': 403,
          'error_code': 'session_not_found',
          'msg': 'Session from session_id claim in JWT does not exist',
        },
      ),
    );

    await expectLater(
      dataSource.fetchAssignments(),
      throwsA(isA<CanvasSessionExpiredException>()),
    );
  });

  test('maps 403 session_not_found function exception to CanvasSessionExpiredException', () async {
    final dataSource = _TestCanvasAssignmentRemoteDataSource(
      error: const FunctionException(
        status: 403,
        details: {
          'code': 403,
          'error_code': 'session_not_found',
          'msg': 'Session from session_id claim in JWT does not exist',
        },
        reasonPhrase: 'Forbidden',
      ),
    );

    await expectLater(
      dataSource.fetchAssignments(),
      throwsA(isA<CanvasSessionExpiredException>()),
    );
  });
}
