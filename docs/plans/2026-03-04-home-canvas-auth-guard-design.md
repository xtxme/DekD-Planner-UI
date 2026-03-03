# Home Canvas Auth Guard Design

## Goal

Prevent Home Canvas assignment sync from calling protected Supabase Edge Functions when the Supabase session is missing or expired, and recover by signing the user out to the login screen.

## Chosen Approach

Use the existing `verify_jwt = true` protection on the Edge Function and fix the client-side auth flow instead of weakening function security.

The app will treat missing/expired `currentSession` as the source of truth. When Home assignment sync detects no usable session, it will:

1. Stop before invoking the Edge Function.
2. Surface a session-expired error instead of a raw `FunctionException`.
3. Sign the user out and clear local auth cache.
4. Redirect the user to `/login`.

## Why This Approach

- Keeps Canvas proxy protected behind Supabase auth.
- Fixes the real mismatch between cached UI identity and actual Supabase session state.
- Avoids exposing raw infrastructure errors like `Invalid JWT` to end users.

## Scope

Modify:

- `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`
- `lib/features/home/home_page.dart`

Potentially reuse:

- `lib/features/auth/presentation/providers/auth_session_provider.dart`
- `lib/features/settings/settings_page.dart`

## Data Flow

1. Home watches assignment provider.
2. Data source checks `client.auth.currentSession`.
3. If absent, throw a domain-meaningful auth/session error before `functions.invoke`.
4. Home listens for that auth error.
5. Home signs out, clears cache, invalidates auth provider, and navigates to login.
6. Non-auth errors still render in the existing error card.

## Error Handling

- Missing/expired session: redirect to login and show a short SnackBar.
- Function 401/Invalid JWT fallback: map to the same session-expired path in case the session disappears mid-request.
- Canvas/API/data format errors: keep existing retry card behavior.

## Testing Strategy

Given the current project state has minimal automated coverage around auth/navigation, implementation will focus on:

- deterministic session checks in the data source
- centralized error mapping for auth failures
- manual verification of login -> Home -> expired session -> redirect flow
