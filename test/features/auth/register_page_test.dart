import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/auth/data/local/auth_local_cache_dao.dart';
import 'package:my_first_app/features/auth/data/remote/supabase_auth_service.dart';
import 'package:my_first_app/features/auth/domain/models/auth_user.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/features/auth/register_page.dart';

class _FakeAuthLocalCacheDao implements AuthLocalCacheDao {
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
  _FakeAuthRemoteService({this.registerResult, this.registerError});

  final AuthRegistrationResult? registerResult;
  final Object? registerError;

  @override
  Future<AuthUser?> currentUser() async => null;

  @override
  Future<AuthRegistrationResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (registerError != null) {
      throw registerError!;
    }

    return registerResult ??
        const AuthRegistrationResult(user: null, hasActiveSession: false);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser?> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updatePassword({required String newPassword}) {
    throw UnimplementedError();
  }
}

Widget _buildTestApp({
  required AuthRemoteService remoteService,
  required AuthLocalCacheDao localCacheDao,
}) {
  return ProviderScope(
    overrides: [
      authRemoteServiceProvider.overrideWithValue(remoteService),
      authLocalCacheDaoProvider.overrideWithValue(localCacheDao),
    ],
    child: MaterialApp(
      home: const RegisterPage(),
      routes: {
        '/login': (_) =>
            const Scaffold(body: Center(child: Text('Login Page'))),
      },
    ),
  );
}

void main() {
  Future<void> fillAndSubmit(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    final registerButton = find.widgetWithText(ElevatedButton, 'Register');

    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), 'test@example.com');
    await tester.enterText(fields.at(2), 'Password123!');
    await tester.enterText(fields.at(3), 'Password123!');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'redirects to login when sign up completes without an active session',
    (tester) async {
      final localCache = _FakeAuthLocalCacheDao();
      final remoteService = _FakeAuthRemoteService(
        registerResult: const AuthRegistrationResult(
          user: AuthUser(
            uid: 'user-1',
            email: 'test@example.com',
            displayName: 'Test User',
          ),
          hasActiveSession: false,
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(remoteService: remoteService, localCacheDao: localCache),
      );

      await fillAndSubmit(tester);
      expect(find.text('Login Page'), findsOneWidget);
      expect(await localCache.readSession(), isNull);
    },
  );

  testWidgets(
    'shows a backend connectivity message when sign up cannot reach Supabase',
    (tester) async {
      final localCache = _FakeAuthLocalCacheDao();
      final remoteService = _FakeAuthRemoteService(
        registerError: const SocketException(
          'Failed host lookup: lhtffjttpachjjntvssj.supabase.co',
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(remoteService: remoteService, localCacheDao: localCache),
      );

      await fillAndSubmit(tester);
      expect(
        find.textContaining('Could not reach the authentication server'),
        findsOneWidget,
      );
      expect(find.text('Login Page'), findsNothing);
    },
  );
}
