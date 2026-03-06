import 'package:flutter/foundation.dart';
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
        response = await _client.functions.invoke('canvas-proxy');
        debugPrint('CANVAS_DEBUG: Proxy response status: ${response.status}');

        // If not auth failure, break out of retry loop
        if (!_isAuthFailureStatus(response.status, response.data)) {
          break;
        }

        // If auth failure and we have retries left, retry
        if (retryCount < 2) {
          debugPrint(
            'CANVAS_DEBUG: ⚠️  Got auth failure, retrying... (${retryCount + 1}/3)',
          );
          retryCount++;
          await Future.delayed(Duration(milliseconds: 200 * retryCount));
        } else {
          // Last retry failed, throw exception
          debugPrint('CANVAS_DEBUG: ❌ All retries failed, throwing exception');
          throw const CanvasSessionExpiredException();
        }
      }

      if (_isAuthFailureStatus(response!.status, response.data)) {
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
      if (_client.auth.currentSession != null) {
        return;
      }
      await Future<void>.delayed(_sessionPropagationDelay);
    }
    throw const CanvasSessionExpiredException();
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
