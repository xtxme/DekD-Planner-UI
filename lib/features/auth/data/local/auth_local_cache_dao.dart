import 'package:my_first_app/features/auth/domain/models/auth_user.dart';

abstract class AuthLocalCacheDao {
  Future<void> saveSession(AuthUser user);
  Future<AuthUser?> readSession();
  Future<void> clearSession();
}
