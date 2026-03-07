# Local Notification Deadline Reminder Design

**Date:** 2026-03-06  
**Status:** Approved

## Goal
Enable iPhone local notifications for assignment reminders without APNs/Firebase, based on user reminder preferences, and only for assignments that are not completed.

## Scope
- Use local notifications only.
- Trigger reminder resync on app startup and after assignment add/edit/delete.
- Respect notification settings from `user_notification_preferences`.
- Exclude completed assignments.

## Architecture
- Add `LocalNotificationService` in `lib/core/notifications/` for initialize, permission handling, schedule, and cancellation.
- Add `AssignmentReminderScheduler` in `lib/features/assignments/` to translate assignments + settings into scheduled reminder jobs.
- Use deterministic notification IDs (`assignment + offset`) so schedules can be replaced safely on each sync.
- Add startup reminder sync after app initialization.

## Data Flow
1. App startup:
- Initialize local notification plugin.
- Request permissions on iOS.
- If user session exists, fetch assignment rows and notification preferences.
- Run full reminder resync.

2. Assignment mutation:
- After add/edit/delete success, invalidate assignment providers and run reminder resync.

3. Settings apply:
- Save preferences to Supabase and run reminder resync.

4. Scheduler rules:
- Include only rows with `status != completed`.
- Build offsets from selected presets + custom amount/unit.
- Schedule only future reminder times (`dueAt - offset > now`).
- Cancel existing scheduled reminders before writing the new set.

## Error Handling
- Permission denied: continue app flow, skip scheduling, and show a brief settings message.
- Scheduling failure for one assignment: log and continue remaining schedules.
- Temporary backend read failure: do not crash; keep app functional.

## Testing Strategy
- Unit test scheduler offset and filtering logic.
- Widget/integration smoke for settings apply and resync trigger.
- Manual iPhone test:
  - create near-term assignment reminder,
  - edit due date and verify reminder replacement,
  - mark/delete and verify cancellation.

## Out of Scope
- Remote push notifications.
- Background periodic resync workers.
- Rich notification actions/categories.
