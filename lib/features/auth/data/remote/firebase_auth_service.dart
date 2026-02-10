import 'package:my_first_app/features/auth/domain/models/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

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

class FirebaseAuthServiceImpl implements FirebaseAuthService {
  FirebaseAuthServiceImpl(this._auth);

  final fb.FirebaseAuth _auth;

  @override
  Future<AuthUser?> signIn({
    required String email, 
    required String password
    }) async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return _mapUser(credential.user);
  }

  @override
  Future<AuthUser?> register({
    required String email, 
    required String password
    }) async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        );
    return _mapUser(credential.user);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AuthUser?> currentUser() async => _mapUser(_auth.currentUser);
  
  AuthUser? _mapUser(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid, 
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }  
}
  
