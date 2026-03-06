import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

//ตั้งค่าเชื่อม Supabase ตอนเปิดแอป
class SupabaseInitializer {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      httpClient: _SupabaseLoggingHttpClient(http.Client()),
    );

    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) {
      return;
    }

    try {
      await client.auth.getUser(session.accessToken);
    } on AuthException catch (error) {
      final normalized = error.message.toLowerCase();
      final isInvalidJwt = normalized.contains('invalid jwt') ||
          normalized.contains('session_not_found') ||
          normalized.contains(
            'session from session_id claim in jwt does not exist',
          ) ||
          normalized.contains('invalid or expired token');
      if (isInvalidJwt) {
        await client.auth.signOut(scope: SignOutScope.local);
      }
    }
  }
}

class _SupabaseLoggingHttpClient extends http.BaseClient {
  _SupabaseLoggingHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final url = request.url.toString();
    if (url.contains('/functions/v1/')) {
      final authHeader = request.headers['Authorization'];
      final apikey = request.headers['apikey'];
      final previewLength = authHeader == null
          ? 0
          : (authHeader.length < 28 ? authHeader.length : 28);
      final authPreview = authHeader == null
          ? 'NONE'
          : '${authHeader.substring(0, previewLength)}... (len=${authHeader.length})';
      // ignore: avoid_print
      print('CANVAS_HTTP_DEBUG: ${request.method} $url');
      // ignore: avoid_print
      print('CANVAS_HTTP_DEBUG: Authorization=$authPreview');
      // ignore: avoid_print
      print('CANVAS_HTTP_DEBUG: apikey_present=${apikey != null}');
    }
    return _inner.send(request);
  }
}
