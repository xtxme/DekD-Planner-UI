# Home Canvas Auth Guard Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Keep Home able to load Canvas assignments whenever a real Supabase session exists, and stop stale cached auth data from masking an expired session.

**Architecture:** Make Supabase auth the single source of truth by clearing stale cached auth state when remote auth is missing, keep the Home Canvas remote data source auth-aware, and handle expired-session errors in Home by cleaning up auth state and redirecting to `/login`. Keep existing retry UI for non-auth sync failures.

**Tech Stack:** Flutter, Riverpod, supabase_flutter

---

### Task 1: Fix auth state source of truth

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_session_provider.dart`
- Modify: `lib/features/auth/login_page.dart`
- Test: `test/features/auth/presentation/providers/auth_session_provider_test.dart`

**Step 1: Write the failing test**

Update the provider test to assert that a missing remote user clears stale cache and resolves to `null` instead of returning cached identity.

**Step 2: Implement the minimal code**

- Make `authSessionProvider` treat remote Supabase auth as the source of truth.
- Clear local cache when remote auth is absent.
- Adjust login flow so it no longer relies on stale cached user fallback.

**Step 3: Verify behavior**

Run the focused auth provider test and manually verify login still navigates into the app.

**Step 4: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_session_provider.dart lib/features/auth/login_page.dart test/features/auth/presentation/providers/auth_session_provider_test.dart
git commit -m "fix: align auth session state with Supabase"
```

### Task 2: Keep Home Canvas fetch auth-aware

**Files:**
- Modify: `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`
- Modify: `lib/features/home/home_page.dart`

**Step 1: Write the failing test**

Keep existing focused provider tests and use a manual verification path for Home navigation.

**Step 2: Implement the minimal code**

- Keep the Canvas session guard in the data source.
- Map auth failures to `CanvasSessionExpiredException`.
- Ensure Home responds to that error once, clears providers, and redirects cleanly.

**Step 3: Verify behavior**

Manual: log in, open Home, confirm Canvas assignments render with a valid session, then simulate/use an expired session and confirm redirect to login occurs once.

**Step 4: Commit**

```bash
git add lib/features/home/data/remote/canvas_assignment_remote_data_source.dart lib/features/home/home_page.dart
git commit -m "fix: guard home canvas fetch with real auth state"
```

### Task 3: Regression check

**Files:**
- Verify: `lib/features/settings/settings_page.dart`
- Test: `test/features/home/presentation/providers/home_tasks_provider_test.dart`

**Step 1: Compare sign-out flow**

Reuse the existing sign-out semantics from Settings so Home cleanup does not diverge from the rest of the app.

**Step 2: Run verification**

Run:

```bash
flutter test test/features/auth/presentation/providers/auth_session_provider_test.dart
flutter test test/features/home/presentation/providers/home_tasks_provider_test.dart
flutter analyze
```

Expected: focused tests pass and no new analysis errors from the auth/auth-guard changes.

**Step 3: Commit**

```bash
git add docs/plans/2026-03-04-home-canvas-auth-guard-design.md docs/plans/2026-03-04-home-canvas-auth-guard.md lib/features/home/data/remote/canvas_assignment_remote_data_source.dart lib/features/home/home_page.dart
git commit -m "docs: plan home canvas auth guard"
```
