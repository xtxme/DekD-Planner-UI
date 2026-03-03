import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CanvasSessionExpiredException implements Exception {
  const CanvasSessionExpiredException([
    this.message = 'Your session expired. Please sign in again.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class CanvasAssignmentRemoteDataSource {
  const CanvasAssignmentRemoteDataSource({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  Future<List<CanvasAssignment>> fetchAssignments() async {
    if (_client.auth.currentSession == null) {
      throw const CanvasSessionExpiredException();
    }

    try {
      final response = await _client.functions.invoke(
        'canvas-assignments-proxy',
      );

      final data = response.data;
      if (data is! List) {
        throw const FormatException(
          'Canvas assignments proxy returned an invalid response.',
        );
      }

      return data
          .whereType<Map>()
          .map(
            (item) => CanvasAssignment.fromMap(Map<String, dynamic>.from(item)),
          )
          .where(
            (assignment) =>
                assignment.id != 0 &&
                assignment.name.isNotEmpty &&
                assignment.dueAt != null,
          )
          .toList();
    } on FunctionException catch (error) {
      if (_isAuthFailure(error)) {
        throw const CanvasSessionExpiredException();
      }
      throw Exception(_extractErrorMessage(error.details));
    } on AuthException catch (_) {
      throw const CanvasSessionExpiredException();
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return 'Canvas assignment sync failed.';
  }

  bool _isAuthFailure(FunctionException error) {
    if (error.status == 401) {
      return true;
    }

    final details = error.details?.toString().toLowerCase() ?? '';
    final reasonPhrase = error.reasonPhrase?.toLowerCase() ?? '';

    return details.contains('invalid jwt') ||
        details.contains('unauthorized') ||
        reasonPhrase.contains('unauthorized');
  }
}
