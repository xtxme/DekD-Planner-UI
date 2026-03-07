import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/core/notifications/local_notification_service.dart';
import 'package:my_first_app/core/supabase/supabase_client_provider.dart';
import 'package:my_first_app/features/assignments/presentation/providers/assignment_form_provider.dart';
import 'package:my_first_app/features/assignments/services/assignment_reminder_scheduler.dart';
import 'package:my_first_app/features/settings/presentation/providers/settings_providers.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

final assignmentReminderSchedulerProvider =
    Provider<AssignmentReminderScheduler>(
      (ref) => AssignmentReminderScheduler(
        notificationService: ref.watch(localNotificationServiceProvider),
      ),
    );

final assignmentReminderSyncServiceProvider =
    Provider<AssignmentReminderSyncService>(
      (ref) => AssignmentReminderSyncService(ref: ref),
    );

class AssignmentReminderSyncService {
  AssignmentReminderSyncService({required Ref ref}) : _ref = ref;

  final Ref _ref;

  Future<void> initialize() async {
    final service = _ref.read(localNotificationServiceProvider);
    await service.initialize();
    await service.requestPermissions();
  }

  Future<void> resyncIfAuthenticated() async {
    final client = _ref.read(supabaseClientProvider);
    if (client.auth.currentUser == null) {
      return;
    }

    await _resyncForCurrentUser();
  }

  Future<void> _resyncForCurrentUser() async {
    final assignmentDao = _ref.read(assignmentDaoProvider);
    final notificationDao = _ref.read(notificationPreferencesDaoProvider);
    final scheduler = _ref.read(assignmentReminderSchedulerProvider);

    final assignments = await assignmentDao.getAll();
    final preferences = await notificationDao.getOrCreate();

    await scheduler.resyncAll(
      assignments: assignments,
      preferences: preferences,
    );
  }
}
