import 'package:my_first_app/features/auth/domain/models/auth_user.dart';

abstract class FirebaseAuthService {
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser?> register({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<AuthUser?> currentUser();
}
