import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/auth/data/local/auth_local_cache_dao.dart';
import 'package:my_first_app/features/auth/data/remote/supabase_auth_service.dart';
import 'package:my_first_app/features/auth/domain/models/auth_user.dart';

//Provider ที่ผูก Riverpod เข้ากับ SupabaseAuthService:
final authRemoteServiceProvider = Provider<AuthRemoteService>(
  (ref) => SupabaseAuthService(ref.watch(supabaseClientProvider)),
);

final authLocalCacheDaoProvider = Provider<AuthLocalCacheDao>(
  (ref) => InMemoryAuthLocalCacheDao(),
);

final authSessionProvider = FutureProvider<AuthUser?>(
  (ref) async {
    final local = ref.watch(authLocalCacheDaoProvider);
    final remote = ref.watch(authRemoteServiceProvider);

    final cached = await local.readSession();
    if (cached != null) return cached;

    final user = await remote.currentUser();
    if (user != null) {
      await local.saveSession(user);
    }
    return user;
  },
);
