# Home Canvas Auth Guard Design

## Goal

Make Home display Canvas assignments whenever a real Supabase session exists, and stop showing stale signed-in UI when the session has actually expired.

## Chosen Approach

Use the existing `verify_jwt = true` protection on the Edge Function and fix the client-side auth flow instead of weakening function security.

The app will treat Supabase auth as the source of truth instead of letting cached profile data masquerade as an active session. When Home assignment sync detects no usable session, it will:

1. Stop before invoking the Edge Function.
2. Surface a session-expired error instead of a raw `FunctionException`.
3. Clear stale cached auth state instead of reusing it as an active login.
4. Redirect the user to `/login`.

## Why This Approach

- Keeps Canvas proxy protected behind Supabase auth.
- Fixes the real mismatch between cached UI identity and actual Supabase session state.
- Avoids exposing raw infrastructure errors like `Invalid JWT` to end users.
- Prevents Home from showing a name from cache while Canvas correctly refuses the request.

## Scope

Modify:

- `lib/features/auth/presentation/providers/auth_session_provider.dart`
- `lib/features/auth/login_page.dart`
- `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`
- `lib/features/home/home_page.dart`

Potentially reuse:

- `lib/features/auth/presentation/providers/auth_session_provider.dart`
- `lib/features/settings/settings_page.dart`

## Data Flow

1. Auth provider asks Supabase for the current user/session.
2. If Supabase returns no authenticated user, the provider clears stale local cache and returns signed-out state.
3. Home watches assignment provider.
4. Data source checks `client.auth.currentSession`.
5. If absent, throw a domain-meaningful auth/session error before `functions.invoke`.
6. Home listens for that auth error, clears auth-related providers, and navigates to login.
7. Non-auth errors still render in the existing error card.

## Error Handling

- Missing/expired session: redirect to login and show a short SnackBar.
- Function 401/Invalid JWT fallback: map to the same session-expired path in case the session disappears mid-request.
- Canvas/API/data format errors: keep existing retry card behavior.

## Testing Strategy

Given the current project state has minimal automated coverage around auth/navigation, implementation will focus on:

- auth provider behavior when remote auth is null
- deterministic session checks in the data source
- centralized error mapping for auth failures
- manual verification of login -> Home -> expired session -> redirect flow
