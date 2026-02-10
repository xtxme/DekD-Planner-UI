import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:my_first_app/features/auth/data/local/auth_local_cache_dao.dart';
import 'package:my_first_app/features/auth/data/remote/firebase_auth_service.dart';
import 'package:my_first_app/features/auth/domain/models/auth_user.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthServiceImpl(fb.FirebaseAuth.instance),
);

final authLocalCacheDaoProvider = Provider<AuthLocalCacheDao>(
  (ref) => InMemoryAuthLocalCacheDao(),
);

final authSessionProvider = FutureProvider<AuthUser?>(
  (ref) async {
    final local = ref.watch(authLocalCacheDaoProvider);
    final remote = ref.watch(firebaseAuthServiceProvider);

    final cached = await local.readSession();
    if (cached != null) return cached;

    final user = await remote.currentUser();
    if (user != null) {
      await local.saveSession(user);
    }
    return user;
  },
);
