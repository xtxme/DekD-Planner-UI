import 'package:my_first_app/features/auth/domain/models/auth_user.dart';

abstract class AuthLocalCacheDao {
  Future<void> saveSession(AuthUser user);
  Future<AuthUser?> readSession();
  Future<void> clearSession();
}

// Placeholder cache for structure wiring only.

class InMemoryAuthLocalCacheDao implements AuthLocalCacheDao {
  AuthUser? _cache;

  @override
  Future<void> saveSession(AuthUser user) async {
    _cache = user;
  }

  @override
  Future<AuthUser?> readSession() async {
    return _cache;
  }

  @override
  Future<void> clearSession() async {
    _cache = null;
  }
}