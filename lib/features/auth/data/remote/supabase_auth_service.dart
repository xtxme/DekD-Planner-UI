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

    return _mapUser(response.user);
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
  Future<AuthUser?> currentUser() async => _mapUser(_client.auth.currentUser);

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
}
