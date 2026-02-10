import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/auth/data/local/auth_local_cache_dao.dart';
import 'package:my_first_app/features/auth/data/remote/firebase_auth_service.dart';
import 'package:my_first_app/features/auth/domain/models/auth_user.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);

final authLocalCacheDaoProvider = Provider<AuthLocalCacheDao>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);

final authSessionProvider = FutureProvider<AuthUser?>(
  (ref) => throw UnimplementedError('TODO Step 4'),
);
