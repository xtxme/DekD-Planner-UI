import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//ติดต่อกับ Server (ในที่นี้คือ Supabase) เพื่อขอข้อมูลวิชาเรียนมาจาก Canvas LMS แล้วนำมา "ตรวจสอบและจัดระเบียบ" ให้กลายเป็น List ของวิชาเรียนที่พร้อมใช้งานในแอป

class CanvasSessionExpiredException implements Exception {
  const CanvasSessionExpiredException([
    this.message = 'Your session expired. Please sign in again.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class CanvasCourseRemoteDataSource {
  const CanvasCourseRemoteDataSource({
    required SupabaseClient client,
  }) //คลาสนี้มีสิทธิ์ในการเรียกใช้ฟังก์ชันต่างๆ ของ Supabase ได้
  : _client = client;

  static const int _sessionPropagationAttempts = 50;
  static const Duration _sessionPropagationDelay = Duration(milliseconds: 100);

  final SupabaseClient _client;

  Future<List<CanvasCourse>> fetchCourses() async {
    debugPrint(
      'CANVAS_DEBUG: ==================================================',
    );
    debugPrint('CANVAS_DEBUG: Starting fetchCourses()');
    debugPrint(
      'CANVAS_DEBUG: ==================================================',
    );

    await _requireActiveSession();

    debugPrint('CANVAS_DEBUG: ✅ Session ready, calling canvas-proxy');

    try {
      // Retry logic for temporary auth failures
      FunctionResponse? response;
      int retryCount = 0;

      while (retryCount < 3) {
        final session = _client.auth.currentSession;
        if (session == null) {
          throw const CanvasSessionExpiredException();
        }
        await _ensureSessionUsable(session);
        _logTokenClaims(session.accessToken);

        // Ensure no stale auth header overrides the SDK's current session token.
        _client.functions.headers.remove('Authorization');
        _client.functions.headers.remove('authorization');

        try {
          // Let Supabase SDK attach the latest auth token automatically.
          response = await _client.functions.invoke('canvas-proxy');
          debugPrint('CANVAS_DEBUG: Proxy response status: ${response.status}');
          break;
        } on FunctionException catch (error) {
          debugPrint('CANVAS_DEBUG: invoke failed (attempt ${retryCount + 1}/3): $error');
          if (_isAuthFailure(error)) {
            if (retryCount < 2) {
              retryCount++;
              debugPrint(
                'CANVAS_DEBUG: ⚠️ Auth failure, refreshing session then retrying...',
              );
              await _client.auth.refreshSession();
              await Future.delayed(Duration(milliseconds: 200 * retryCount));
              continue;
            }

            final fallbackResponse = await _tryInvokeWithAnonKeyFallback();
            if (fallbackResponse != null) {
              response = fallbackResponse;
              break;
            }
            throw const CanvasSessionExpiredException();
          }
          rethrow;
        }
      }

      if (response == null) {
        throw const CanvasSessionExpiredException();
      }

      if (_isAuthFailureStatus(response.status, response.data)) {
        throw const CanvasSessionExpiredException();
      }

      if (response.status >= 400) {
        throw Exception(
          _extractErrorMessage(response.data),
        ); //เอาข้อความสั้นๆ มาบอกเราว่า "พังเพราะอะไร"
      }

      final data = response.data;
      if (data is! List) {
        throw const FormatException(
          'Canvas proxy returned an invalid response.',
        );
      }

      final courses = data
          .whereType<Map>() //เอาเฉพาะข้อมูลที่เป็น Map (ป้องข้อมูลแปลกปลอม)
          .map(
            (item) => CanvasCourse.fromMap(Map<String, dynamic>.from(item)),
          ) //แปลง Map เป็น Object CanvasCourse
          .where(
            (course) => course.id != 0 && course.name.trim().isNotEmpty,
          ) //กรองทิ้ง! ถ้า ID เป็น 0 หรือชื่อว่าง
          .toList(); //รวมเป็น List ส่งออกไป

      debugPrint(
        'CANVAS_DEBUG: ✅ Successfully parsed ${courses.length} courses',
      );

      return courses;
    } on FunctionException catch (error) {
      debugPrint('CANVAS_DEBUG: ❌ FunctionException: $error');
      if (_isAuthFailure(error)) {
        throw const CanvasSessionExpiredException();
      }
      throw Exception(_extractErrorMessage(error.details));
    } on AuthException catch (error) {
      debugPrint('CANVAS_DEBUG: ❌ AuthException: $error');
      throw const CanvasSessionExpiredException();
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return 'Canvas sync failed.';
  }

  Future<void> _requireActiveSession() async {
    for (var attempt = 0; attempt < _sessionPropagationAttempts; attempt++) {
      final session = _client.auth.currentSession;
      if (session != null) {
        final expiresAt = session.expiresAt ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timeUntilExpiry = expiresAt - now;
        
        debugPrint('CANVAS_DEBUG: Session found - expires in ${timeUntilExpiry}s');
        
        if (timeUntilExpiry <= 60) {
          debugPrint('CANVAS_DEBUG: Token expiring soon, refreshing...');
          try {
            final refreshed = await _client.auth.refreshSession();
            final refreshedSession = refreshed.session ?? _client.auth.currentSession;
            if (refreshedSession == null) {
              throw const CanvasSessionExpiredException();
            }
            await _ensureSessionUsable(refreshedSession);
            debugPrint('CANVAS_DEBUG: ✅ Token refreshed');
            
            // Wait for session to propagate to backend
            final propagationDelay = Duration(milliseconds: 500);
            debugPrint('CANVAS_DEBUG: Waiting ${propagationDelay.inMilliseconds}ms for session propagation...');
            await Future.delayed(propagationDelay);
            debugPrint('CANVAS_DEBUG: ✅ Session propagation complete');
            return;
          } catch (e) {
            debugPrint('CANVAS_DEBUG: ❌ Token refresh failed: $e');
            throw const CanvasSessionExpiredException();
          }
        }
        
        debugPrint('CANVAS_DEBUG: Token valid, expires in ${timeUntilExpiry}s');
        await _ensureSessionUsable(session);
        return;
      }
      await Future<void>.delayed(_sessionPropagationDelay);
    }
    throw const CanvasSessionExpiredException();
  }

  Future<void> _ensureSessionUsable(Session session) async {
    try {
      await _client.auth.getUser(session.accessToken);
      return;
    } on AuthException catch (error) {
      if (!_isLikelyInvalidJwt(error.message)) {
        rethrow;
      }

      debugPrint('CANVAS_DEBUG: Session token rejected by auth, attempting refresh...');
      final refreshed = await _client.auth.refreshSession();
      final refreshedSession = refreshed.session ?? _client.auth.currentSession;
      if (refreshedSession == null) {
        throw const CanvasSessionExpiredException();
      }

      try {
        await _client.auth.getUser(refreshedSession.accessToken);
      } on AuthException catch (secondError) {
        if (_isLikelyInvalidJwt(secondError.message)) {
          throw const CanvasSessionExpiredException();
        }
        rethrow;
      }
    }
  }

  bool _isLikelyInvalidJwt(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('invalid jwt') ||
        normalized.contains('session_not_found') ||
        normalized.contains(
          'session from session_id claim in jwt does not exist',
        ) ||
        normalized.contains('invalid or expired token');
  }

  void _logTokenClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        debugPrint('CANVAS_DEBUG: JWT claim decode skipped (invalid format)');
        return;
      }
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return;
      }
      final iss = decoded['iss'];
      final sub = decoded['sub'];
      final aud = decoded['aud'];
      final sessionId = decoded['session_id'];
      debugPrint(
        'CANVAS_DEBUG: JWT claims iss=$iss aud=$aud sub=$sub session_id=$sessionId',
      );
    } catch (e) {
      debugPrint('CANVAS_DEBUG: JWT claim decode failed: $e');
    }
  }

  Future<FunctionResponse?> _tryInvokeWithAnonKeyFallback() async {
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    if (anonKey.isEmpty) {
      return null;
    }

    debugPrint('CANVAS_DEBUG: Trying anon-key fallback for canvas-proxy');
    try {
      return await _client.functions.invoke(
        'canvas-proxy',
        headers: {
          'Authorization': 'Bearer $anonKey',
          'apikey': anonKey,
        },
      );
    } on FunctionException catch (error) {
      debugPrint('CANVAS_DEBUG: anon-key fallback failed: $error');
      return null;
    }
  }

  bool _isAuthFailure(FunctionException error) {
    if (_isAuthFailureStatus(error.status, error.details)) {
      return true;
    }

    final details = error.details?.toString().toLowerCase() ?? '';
    final reasonPhrase = error.reasonPhrase?.toLowerCase() ?? '';
    return _looksLikeSupabaseSessionError(details) ||
        _looksLikeSupabaseSessionError(reasonPhrase);
  }

  bool _isAuthFailureStatus(int status, dynamic details) {
    if (status == 401) {
      final text = details?.toString().toLowerCase() ?? '';
      return _looksLikeSupabaseSessionError(text);
    }

    if (status != 403) {
      return false;
    }

    if (details is Map) {
      final errorCode = details['error_code']?.toString().toLowerCase() ?? '';
      final message = details['msg']?.toString().toLowerCase() ?? '';
      return errorCode == 'session_not_found' ||
          message.contains(
            'session from session_id claim in jwt does not exist',
          );
    }

    final text = details?.toString().toLowerCase() ?? '';
    return _looksLikeSupabaseSessionError(text);
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
