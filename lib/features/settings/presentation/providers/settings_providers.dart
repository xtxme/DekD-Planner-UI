import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/settings/data/models/notification_preference_row.dart';
import 'package:my_first_app/features/settings/data/models/profile_row.dart';
import 'package:my_first_app/features/settings/data/remote/supabase_notification_preferences_dao.dart';
import 'package:my_first_app/features/settings/data/remote/supabase_profile_dao.dart';

final profileDaoProvider = Provider<SupabaseProfileDao>(
  (ref) => SupabaseProfileDao(client: ref.watch(supabaseClientProvider)),
);

final notificationPreferencesDaoProvider =
    Provider<SupabaseNotificationPreferencesDao>(
  (ref) =>
      SupabaseNotificationPreferencesDao(client: ref.watch(supabaseClientProvider)),
);

final profileProvider = FutureProvider<ProfileRow>(
  (ref) async => ref.watch(profileDaoProvider).getOrCreate(),
);

final notificationPreferencesProvider = FutureProvider<NotificationPreferenceRow>(
  (ref) async => ref.watch(notificationPreferencesDaoProvider).getOrCreate(),
);
