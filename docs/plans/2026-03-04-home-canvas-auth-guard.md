# Home Canvas Auth Guard Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Stop Home from invoking protected Canvas Edge Functions with an invalid auth state and return the user to login when the Supabase session is missing or expired.

**Architecture:** Add a small auth-aware error type in the Home Canvas remote data source, detect missing/expired Supabase sessions before and after function invocation, and handle that error in the Home page by signing out, clearing cached auth state, and redirecting to `/login`. Keep existing retry UI for non-auth sync failures.

**Tech Stack:** Flutter, Riverpod, supabase_flutter

---

### Task 1: Add auth-aware Canvas sync errors

**Files:**
- Modify: `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

**Step 1: Write the failing test**

No focused test file exists yet for this flow in the repository. Use a minimal implementation-first change and validate manually after wiring the redirect behavior.

**Step 2: Implement the minimal code**

- Add a small exception type for expired/missing session cases.
- Check `client.auth.currentSession` before `functions.invoke`.
- Map `FunctionException` 401 and `Invalid JWT` responses to the same auth exception.

**Step 3: Verify behavior**

Manual: launch the app in a state with no valid Supabase session and confirm Home no longer exposes raw `Invalid JWT`.

**Step 4: Commit**

```bash
git add lib/features/home/data/remote/canvas_assignment_remote_data_source.dart
git commit -m "fix: detect expired home canvas session"
```

### Task 2: Redirect on auth-expired errors from Home

**Files:**
- Modify: `lib/features/home/home_page.dart`

**Step 1: Write the failing test**

No widget test harness exists for this navigation path. Keep the change scoped and validate manually.

**Step 2: Implement the minimal code**

- Convert `HomePage` to a `ConsumerStatefulWidget`.
- Listen to the Home assignments provider.
- When the auth/session exception is observed, sign out, clear auth cache, invalidate auth provider, show a SnackBar, and navigate to `/login`.
- Prevent duplicate redirects while async state settles.

**Step 3: Verify behavior**

Manual: log in, open Home, simulate/use an expired session, and confirm redirect to login occurs once.

**Step 4: Commit**

```bash
git add lib/features/home/home_page.dart
git commit -m "fix: redirect expired home canvas sessions"
```

### Task 3: Regression check

**Files:**
- Verify: `lib/features/settings/settings_page.dart`

**Step 1: Compare sign-out flow**

Reuse the existing sign-out semantics from Settings so Home cleanup does not diverge from the rest of the app.

**Step 2: Run verification**

Run:

```bash
flutter analyze
```

Expected: no new analysis errors from the auth guard changes.

**Step 3: Commit**

```bash
git add docs/plans/2026-03-04-home-canvas-auth-guard-design.md docs/plans/2026-03-04-home-canvas-auth-guard.md lib/features/home/data/remote/canvas_assignment_remote_data_source.dart lib/features/home/home_page.dart
git commit -m "docs: plan home canvas auth guard"
```
