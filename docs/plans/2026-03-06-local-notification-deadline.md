# Local Deadline Notifications Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add iOS local notifications for assignment reminders that respect saved reminder preferences and exclude completed assignments.

**Architecture:** Introduce a core notification service for plugin initialization and scheduling primitives, then a feature-level scheduler that converts assignment rows + notification preferences into reminder jobs. Trigger full reminder resync at app startup and after assignment/settings mutations so schedules stay correct without background workers.

**Tech Stack:** Flutter, flutter_local_notifications, timezone, Riverpod, Supabase

---

### Task 1: Add notification dependencies and iOS config

**Files:**
- Modify: `pubspec.yaml`
- Modify: `ios/Runner/Info.plist`

**Step 1: Add packages**
- Add `flutter_local_notifications` and `timezone` under `dependencies`.

**Step 2: Install packages**
Run: `flutter pub get`  
Expected: dependency resolution succeeds and lockfile updates.

**Step 3: Add iOS notification usage description**
- Add `NSUserNotificationUsageDescription` in Info.plist.

**Step 4: Verify iOS project still builds metadata**
Run: `flutter analyze`  
Expected: no new analyzer issues from package integration.

### Task 2: Implement reusable local notification service

**Files:**
- Create: `lib/core/notifications/local_notification_service.dart`

**Step 1: Add service API**
- Define methods for `initialize`, `requestPermissions`, `cancelAllReminders`, `scheduleReminder`, and listing pending requests for debug.

**Step 2: Implement Flutter Local Notifications setup**
- Configure Android + Darwin initialization.
- Configure foreground presentation options for iOS.

**Step 3: Implement zoned scheduling helpers**
- Convert DateTime to TZDateTime in local timezone.
- Ignore past times defensively.

**Step 4: Validate with analyzer**
Run: `flutter analyze lib/core/notifications/local_notification_service.dart`  
Expected: no issues.

### Task 3: Implement assignment reminder scheduler

**Files:**
- Create: `lib/features/assignments/services/assignment_reminder_scheduler.dart`
- Modify: `lib/features/settings/widgets/notification_reminder_card.dart` (shared enums reused by scheduler)

**Step 1: Define reminder offset model**
- Map presets/custom settings into concrete Durations.

**Step 2: Build deterministic notification IDs**
- Use hash-safe composition from assignment id + offset key.

**Step 3: Build full resync API**
- Cancel existing reminders.
- Filter eligible assignments (`status != completed`).
- Schedule reminders only in the future.

**Step 4: Add simple logger hooks**
- Record skipped cases (no id, past time) for debugging.

**Step 5: Validate with analyzer**
Run: `flutter analyze lib/features/assignments/services/assignment_reminder_scheduler.dart`  
Expected: no issues.

### Task 4: Add Riverpod providers for reminder sync

**Files:**
- Create: `lib/features/assignments/presentation/providers/assignment_reminder_provider.dart`
- Modify: `lib/features/assignments/presentation/providers/assignment_form_provider.dart`
- Modify: `lib/features/settings/presentation/providers/settings_providers.dart`

**Step 1: Provide LocalNotificationService and Scheduler**
- Wire providers so UI flows can call a single `resync()` entrypoint.

**Step 2: Implement a notifier/service function for full resync**
- Fetch assignments + notification preference.
- Call scheduler.

**Step 3: Handle no-session case**
- Exit gracefully when user is signed out.

**Step 4: Validate analyzer**
Run: `flutter analyze lib/features/assignments/presentation/providers/assignment_reminder_provider.dart`  
Expected: no issues.

### Task 5: Trigger sync at startup and on assignment mutations

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/features/assignments/add_assignments/add_assignments.dart`
- Modify: `lib/features/assignments/edit_assignments/edit_assignments.dart`

**Step 1: Startup trigger**
- After app boot and when session exists, trigger reminder resync once.

**Step 2: Add flow trigger**
- After successful insert in add page, run reminder resync.

**Step 3: Edit/Delete flow trigger**
- After successful update/insert/delete in edit page, run reminder resync.

**Step 4: Validate flows with analyzer**
Run: `flutter analyze`  
Expected: no new issues.

### Task 6: Persist settings and trigger sync from notification settings page

**Files:**
- Modify: `lib/features/settings/edit_notifi.dart`
- Modify: `lib/features/settings/data/models/notification_preference_row.dart`

**Step 1: Load existing settings into UI state**
- Read `notificationPreferencesProvider` and seed selected presets/custom values.

**Step 2: Save settings on Apply**
- Convert selected UI values into row format and upsert via DAO.

**Step 3: Trigger reminder resync after save**
- Run shared resync entrypoint and show success/failure snackbars.

**Step 4: Validate analyzer**
Run: `flutter analyze lib/features/settings/edit_notifi.dart`  
Expected: no issues.

### Task 7: Add targeted tests for scheduler logic

**Files:**
- Create: `test/features/assignments/services/assignment_reminder_scheduler_test.dart`

**Step 1: Write failing tests**
- Excludes completed assignments.
- Excludes past reminder times.
- Produces expected reminder times for one-day/six-hour/custom rules.

**Step 2: Run tests and confirm fail first**
Run: `flutter test test/features/assignments/services/assignment_reminder_scheduler_test.dart`  
Expected: FAIL initially.

**Step 3: Implement minimal code updates to pass**
- Update scheduler behavior only as needed.

**Step 4: Run tests and confirm pass**
Run: `flutter test test/features/assignments/services/assignment_reminder_scheduler_test.dart`  
Expected: PASS.

**Step 5: Final validation**
Run: `flutter analyze && flutter test`  
Expected: existing baseline + new tests pass.
