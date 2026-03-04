import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/auth/data/local/auth_local_cache_dao.dart';
import 'package:my_first_app/features/auth/data/remote/supabase_auth_service.dart';
import 'package:my_first_app/features/auth/domain/models/auth_user.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';

class _FakeAuthLocalCacheDao implements AuthLocalCacheDao {
  _FakeAuthLocalCacheDao(this._cachedUser);

  AuthUser? _cachedUser;

  @override
  Future<void> clearSession() async {
    _cachedUser = null;
  }

  @override
  Future<AuthUser?> readSession() async => _cachedUser;

  @override
  Future<void> saveSession(AuthUser user) async {
    _cachedUser = user;
  }
}

class _FakeAuthRemoteService implements AuthRemoteService {
  _FakeAuthRemoteService({required this.currentUserResult});

  final AuthUser? currentUserResult;

  @override
  Future<AuthUser?> currentUser() async => currentUserResult;

  @override
  Future<AuthUser?> register({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    return Future.value();
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    throw UnimplementedError();
  }
}

void main() {
  test(
    'authSessionProvider clears stale cache when remote auth is null',
    () async {
      const cachedUser = AuthUser(
        uid: 'user-1',
        email: 'tt.icy013@gmail.com',
        displayName: 'Icy',
      );

      final local = _FakeAuthLocalCacheDao(cachedUser);
      final container = ProviderContainer(
        overrides: [
          authLocalCacheDaoProvider.overrideWithValue(local),
          authRemoteServiceProvider.overrideWithValue(
            _FakeAuthRemoteService(currentUserResult: null),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(authSessionProvider.future);

      expect(result, isNull);
      expect(await local.readSession(), isNull);
    },
  );

  test('authSessionProvider refreshes cache when remote user is available', () async {
    const cachedUser = AuthUser(
      uid: 'user-1',
      email: 'old@example.com',
      displayName: 'Old Name',
    );
    const remoteUser = AuthUser(
      uid: 'user-1',
      email: 'tt.icy013@gmail.com',
      displayName: 'Icy',
    );

    final local = _FakeAuthLocalCacheDao(cachedUser);
    final container = ProviderContainer(
      overrides: [
        authLocalCacheDaoProvider.overrideWithValue(local),
        authRemoteServiceProvider.overrideWithValue(
          _FakeAuthRemoteService(currentUserResult: remoteUser),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(authSessionProvider.future);

    expect(result, remoteUser);
    expect(await local.readSession(), remoteUser);
  });
}
