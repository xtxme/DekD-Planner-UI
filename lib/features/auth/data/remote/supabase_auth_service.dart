import 'dart:convert';

import 'package:my_first_app/features/auth/domain/models/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

abstract class AuthRemoteService {
  Future<AuthUser?> signIn({required String email, required String password});

  Future<AuthUser?> register({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<AuthUser?> currentUser();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword({required String newPassword});
}

class SupabaseAuthService implements AuthRemoteService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;
    if (session == null) {
      throw const AuthException('Login completed without an active session.');
    }

    final userResponse = await _client.auth.getUser(session.accessToken);
    return _mapUser(userResponse.user);
  }

  @override
  Future<AuthUser?> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName == null || displayName.trim().isEmpty
          ? null
          : {'display_name': displayName.trim()},
    );
    return _mapUser(response.user);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<AuthUser?> currentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      _logCurrentUserCheck('AUTH_DEBUG', 'currentUser(): no current session');
      return null;
    }

    final payload = _decodeJwtPayload(session.accessToken);
    final sessionId = payload['session_id']?.toString() ?? '';
    _logCurrentUserCheck(
      'AUTH_DEBUG',
      'currentUser(): validating remote user '
          'userId=${session.user.id} sessionId=$sessionId expiresAt=${session.expiresAt}',
    );

    try {
      final userResponse = await _client.auth.getUser(session.accessToken);
      _logCurrentUserCheck(
        'AUTH_DEBUG',
        'currentUser(): getUser succeeded userId=${userResponse.user?.id}',
      );
      return _mapUser(userResponse.user);
    } on AuthException catch (error) {
      _logCurrentUserCheck(
        'AUTH_DEBUG',
        'currentUser(): getUser failed '
            'message=${error.message} '
            'userId=${session.user.id} '
            'sessionId=$sessionId '
            'expiresAt=${session.expiresAt}',
      );
      await _client.auth.signOut(scope: SignOutScope.local);
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    final displayName = user.userMetadata?['display_name'] as String?;
    return AuthUser(
      uid: user.id,
      email: user.email ?? '',
      displayName: displayName,
    );
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return const {};
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return const {};
  }

  void _logCurrentUserCheck(String tag, String message) {
    // ignore: avoid_print
    print('$tag: $message');
  }
}
