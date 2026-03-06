import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  static const int _sessionPropagationAttempts = 50;
  static const Duration _sessionPropagationDelay = Duration(milliseconds: 100);

  final SupabaseClient _client;

  void _logSessionState(String label) {
    final session = _client.auth.currentSession;
    debugPrint(
      'CANVAS_DEBUG: --------------------------------------------------',
    );
    debugPrint('CANVAS_DEBUG: $label');
    debugPrint(
      'CANVAS_DEBUG: --------------------------------------------------',
    );
    debugPrint('CANVAS_DEBUG: Session exists: ${session != null}');

    if (session != null) {
      _logSessionDetails(session);
    } else {
      debugPrint('CANVAS_DEBUG: Session is NULL');
    }
    debugPrint(
      'CANVAS_DEBUG: --------------------------------------------------',
    );
  }

  void _logSessionDetails(Session session) {
    debugPrint('CANVAS_DEBUG: User ID: ${session.user.id}');
    debugPrint('CANVAS_DEBUG: User Email: ${session.user.email}');
    debugPrint(
      'CANVAS_DEBUG: Session ID: ${_getSessionId(session.accessToken)}',
    );
    debugPrint('CANVAS_DEBUG: Expires At: ${session.expiresAt}');
    debugPrint(
      'CANVAS_DEBUG: Access Token (first 50 chars): ${session.accessToken.substring(0, 50)}...',
    );

    if (session.expiresAt != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      final now = DateTime.now();
      final timeLeft = expiresAt.difference(now);

      debugPrint(
        'CANVAS_DEBUG: Time until expiry: ${timeLeft.inMinutes} minutes',
      );
      debugPrint('CANVAS_DEBUG: Is expired: ${timeLeft.isNegative}');
    }
  }

  String _getSessionId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return 'N/A';

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded['session_id']?.toString() ?? 'N/A';
      }
    } catch (e) {
      debugPrint('CANVAS_DEBUG: Failed to decode session_id: $e');
    }
    return 'N/A';
  }

  Future<CanvasAssignmentsResponse> fetchAssignmentsWithUser() async {
    debugPrint(
      'CANVAS_DEBUG: ==================================================',
    );
    debugPrint('CANVAS_DEBUG: Starting fetchAssignmentsWithUser()');
    debugPrint(
      'CANVAS_DEBUG: ==================================================',
    );

    _logSessionState('BEFORE requireActiveSession');

    await requireActiveSession();

    _logSessionState('AFTER requireActiveSession');

    try {
      debugPrint('CANVAS_DEBUG: Calling invokeAssignmentsProxy()...');
      final response = await invokeAssignmentsProxy();

      debugPrint('CANVAS_DEBUG: Proxy response received');
      debugPrint('CANVAS_DEBUG: Status: ${response.status}');
      debugPrint('CANVAS_DEBUG: Data type: ${response.data.runtimeType}');

      if (_isAuthFailureStatus(response.status, response.data)) {
        debugPrint('CANVAS_DEBUG: ❌ AUTH FAILURE DETECTED!');
        debugPrint('CANVAS_DEBUG: Response data: ${response.data}');
        throw const CanvasSessionExpiredException();
      }

      if (response.status >= 400) {
        final errorMsg = _extractErrorMessage(response.data);
        debugPrint(
          'CANVAS_DEBUG: ❌ ERROR RESPONSE (status ${response.status})',
        );
        debugPrint('CANVAS_DEBUG: Error message: $errorMsg');
        throw Exception(errorMsg);
      }

      final data = response.data;
      if (data is! Map) {
        debugPrint('CANVAS_DEBUG: ❌ INVALID RESPONSE FORMAT');
        debugPrint('CANVAS_DEBUG: Expected Map, got ${data.runtimeType}');
        throw const FormatException(
          'Canvas assignments proxy returned an invalid response.',
        );
      }

      final map = Map<String, dynamic>.from(data);
      debugPrint('CANVAS_DEBUG: Response keys: ${map.keys.join(", ")}');
      debugPrint('CANVAS_DEBUG: User data: ${map['user']}');
      debugPrint(
        'CANVAS_DEBUG: Assignments count: ${map['assignments']?.length ?? 0}',
      );

      final result = CanvasAssignmentsResponse.fromMap(map);

      debugPrint('CANVAS_DEBUG: ✅ SUCCESSFULLY PARSED RESPONSE');
      debugPrint('CANVAS_DEBUG: User email: ${result.user.email}');
      debugPrint('CANVAS_DEBUG: Assignments: ${result.assignments.length}');
      debugPrint(
        'CANVAS_DEBUG: ==================================================',
      );

      return result;
    } on FunctionException catch (error) {
      debugPrint('CANVAS_DEBUG: ❌ FunctionException caught');
      debugPrint('CANVAS_DEBUG: Status: ${error.status}');
      debugPrint('CANVAS_DEBUG: Details: ${error.details}');

      // RETHROW to let invokeAssignmentsProxy() retry logic handle auth failures
      // Only throw CanvasSessionExpiredException if retries were exhausted
      if (_isAuthFailure(error)) {
        debugPrint('CANVAS_DEBUG: ❌ AUTH FAILURE FROM EXCEPTION');
        debugPrint('CANVAS_DEBUG: ⚠️  Rethrowing to allow retry');
        rethrow;
      }

      // For non-auth errors, wrap in a regular Exception
      throw Exception(_extractErrorMessage(error.details));
    } on AuthException catch (error) {
      debugPrint('CANVAS_DEBUG: ❌ AuthException caught');
      debugPrint('CANVAS_DEBUG: Message: ${error.message}');
      throw const CanvasSessionExpiredException();
    } catch (error, stackTrace) {
      debugPrint('CANVAS_DEBUG: ❌ UNEXPECTED ERROR');
      debugPrint('CANVAS_DEBUG: Error: $error');
      debugPrint('CANVAS_DEBUG: Type: ${error.runtimeType}');
      debugPrint('CANVAS_DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @Deprecated('Use fetchAssignmentsWithUser() instead')
  Future<List<CanvasAssignment>> fetchAssignments() async {
    final response = await fetchAssignmentsWithUser();
    return response.assignments;
  }

  Future<CanvasAssignmentDetails> fetchAssignmentDetails({
    required int assignmentId,
    required int courseId,
  }) async {
    await requireActiveSession();

    try {
      final response = await _client.functions.invoke(
        'canvas-assignment-details-proxy',
        method: HttpMethod.get,
        queryParameters: {
          'assignment_id': assignmentId.toString(),
          'course_id': courseId.toString(),
        },
      );

      if (_isAuthFailureStatus(response.status, response.data)) {
        throw const CanvasSessionExpiredException();
      }

      if (response.status >= 400) {
        throw Exception(_extractErrorMessage(response.data));
      }

      final data = response.data;
      if (data is! Map) {
        throw const FormatException(
          'Canvas assignment details proxy returned an invalid response.',
        );
      }

      return CanvasAssignmentDetails.fromMap(Map<String, dynamic>.from(data));
    } on FunctionException catch (error) {
      if (_isAuthFailure(error)) {
        throw const CanvasSessionExpiredException();
      }
      throw Exception(_extractErrorMessage(error.details));
    } on AuthException {
      throw const CanvasSessionExpiredException();
    }
  }

  Future<void> requireActiveSession() async {
    debugPrint('CANVAS_DEBUG: requireActiveSession() - waiting for session...');

    for (var attempt = 0; attempt < _sessionPropagationAttempts; attempt++) {
      final session = _client.auth.currentSession;

      if (attempt == 0) {
        debugPrint(
          'CANVAS_DEBUG: Initial session state: ${session != null ? "EXISTS" : "NULL"}',
        );
        if (session != null) {
          _logSessionDetails(session);
        }
      }

      if (session != null) {
        debugPrint(
          'CANVAS_DEBUG: ✅ Session found after ${attempt * _sessionPropagationDelay.inMilliseconds}ms',
        );
        return;
      }

      if (attempt % 10 == 0 && attempt > 0) {
        debugPrint(
          'CANVAS_DEBUG: Still waiting... (${attempt * _sessionPropagationDelay.inMilliseconds}ms elapsed)',
        );
      }

      await Future<void>.delayed(_sessionPropagationDelay);
    }

    debugPrint(
      'CANVAS_DEBUG: ❌ SESSION NOT READY AFTER ${_sessionPropagationAttempts * _sessionPropagationDelay.inMilliseconds}ms',
    );
    debugPrint(
      'CANVAS_DEBUG: Final session state: ${_client.auth.currentSession != null ? "EXISTS" : "NULL"}',
    );
    throw const CanvasSessionExpiredException();
  }

  Future<FunctionResponse> invokeAssignmentsProxy({int retryCount = 0}) async {
    debugPrint(
      'CANVAS_DEBUG: invokeAssignmentsProxy() - calling Supabase Edge Function',
    );

    final session = _client.auth.currentSession;
    if (session != null) {
      debugPrint('CANVAS_DEBUG: Sending request WITH session');
      debugPrint('CANVAS_DEBUG: User ID: ${session.user.id}');
      debugPrint(
        'CANVAS_DEBUG: Access token (first 50 chars): ${session.accessToken.substring(0, 50)}...',
      );
    } else {
      debugPrint('CANVAS_DEBUG: ⚠️  SENDING REQUEST WITHOUT SESSION!');
    }

    try {
      final response = await _client.functions.invoke(
        'canvas-assignments-proxy',
      );

      debugPrint('CANVAS_DEBUG: Proxy response status: ${response.status}');

      // Retry on temporary auth failures (token sync issues)
      if (_isAuthFailureStatus(response.status, response.data) &&
          retryCount < 3) {
        debugPrint(
          'CANVAS_DEBUG: ⚠️  Got auth failure, retrying... (${retryCount + 1}/3)',
        );
        await Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)));

        return invokeAssignmentsProxy(retryCount: retryCount + 1);
      }

      return response;
    } catch (e) {
      debugPrint('CANVAS_DEBUG: ❌ Error invoking proxy: $e');
      rethrow;
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return 'Canvas assignment sync failed.';
  }

  bool _isAuthFailure(FunctionException error) {
    if (_isAuthFailureStatus(error.status, error.details)) {
      return true;
    }

    final details = error.details?.toString().toLowerCase() ?? '';
    final reasonPhrase = error.reasonPhrase?.toLowerCase() ?? '';

    debugPrint('CANVAS_DEBUG: Checking auth failure in details...');
    debugPrint('CANVAS_DEBUG: Details: $details');
    debugPrint('CANVAS_DEBUG: Reason phrase: $reasonPhrase');

    final isAuthError =
        _looksLikeSupabaseSessionError(details) ||
        _looksLikeSupabaseSessionError(reasonPhrase);

    debugPrint('CANVAS_DEBUG: Is auth error: $isAuthError');
    return isAuthError;
  }

  bool _isAuthFailureStatus(int status, dynamic details) {
    debugPrint('CANVAS_DEBUG: Checking auth failure status...');
    debugPrint('CANVAS_DEBUG: Status: $status');
    debugPrint('CANVAS_DEBUG: Details: $details');

    if (status == 401) {
      final text = details?.toString().toLowerCase() ?? '';
      final isSupabaseSessionFailure = _looksLikeSupabaseSessionError(text);
      debugPrint(
        'CANVAS_DEBUG: Status 401 detected, Supabase session failure = $isSupabaseSessionFailure',
      );
      return isSupabaseSessionFailure;
    }

    if (status != 403) {
      debugPrint('CANVAS_DEBUG: Status is not 403, not an auth failure');
      return false;
    }

    if (details is Map) {
      final errorCode = details['error_code']?.toString().toLowerCase() ?? '';
      final message = details['msg']?.toString().toLowerCase() ?? '';
      final isSessionNotFound =
          errorCode == 'session_not_found' ||
          message.contains(
            'session from session_id claim in jwt does not exist',
          );

      debugPrint('CANVAS_DEBUG: Is session not found: $isSessionNotFound');
      return isSessionNotFound;
    }

    final text = details?.toString().toLowerCase() ?? '';
    final isSessionNotFound = _looksLikeSupabaseSessionError(text);

    debugPrint('CANVAS_DEBUG: Is session not found (text): $isSessionNotFound');
    return isSessionNotFound;
  }

  bool _looksLikeSupabaseSessionError(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('session_not_found') ||
        normalized.contains('invalid jwt') ||
        normalized.contains(
          'session from session_id claim in jwt does not exist',
        );
  }
}
