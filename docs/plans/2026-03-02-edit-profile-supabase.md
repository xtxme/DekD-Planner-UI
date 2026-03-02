# Edit Profile Supabase Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Load the Edit Profile form from the authenticated user's profile row and save changes back to Supabase.

**Architecture:** Reuse the existing `profileProvider`, `profileDaoProvider`, and `authSessionProvider` instead of introducing a new state layer. Keep the page as a `ConsumerStatefulWidget`, seed controllers once after async data arrives, and upsert changes through the existing `SupabaseProfileDao`.

**Tech Stack:** Flutter, Riverpod, Supabase Flutter

---

### Task 1: Wire Edit Profile to Existing Providers

**Files:**
- Modify: `lib/features/settings/edit_profile.dart`
- Reference: `lib/features/settings/presentation/providers/settings_providers.dart`
- Reference: `lib/features/auth/presentation/providers/auth_session_provider.dart`

**Step 1: Read async profile and auth session data**

Add `ref.watch(profileProvider)` and `ref.watch(authSessionProvider)` in `build()`.

**Step 2: Seed controllers once**

Add widget state flags so the text controllers are populated from provider data only after the initial load succeeds.

**Step 3: Render loading and error states**

Show a progress indicator while profile/auth data loads and show a simple retryable error state if fetching fails.

### Task 2: Save Changes Back to Supabase

**Files:**
- Modify: `lib/features/settings/edit_profile.dart`
- Reference: `lib/features/settings/data/remote/supabase_profile_dao.dart`
- Reference: `lib/features/settings/data/models/profile_row.dart`

**Step 1: Build updated profile payload**

Create a `ProfileRow` from the existing row plus edited `displayName` and `bio`.

**Step 2: Persist with DAO**

Call `ref.read(profileDaoProvider).upsert(updatedRow)`.

**Step 3: Refresh consumers**

Invalidate `profileProvider` after save so dependent screens can reload fresh data.

**Step 4: Show feedback**

Disable save while the request is in flight and show success/error snackbars.

### Task 3: Verification

**Files:**
- Modify: `lib/features/settings/edit_profile.dart`

**Step 1: Run formatter**

Run `dart format lib/features/settings/edit_profile.dart`.

**Step 2: Run a focused static check**

Run `flutter analyze lib/features/settings/edit_profile.dart`.
