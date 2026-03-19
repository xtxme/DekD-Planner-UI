# Subject Icon Release Build Design

**Date:** 2026-03-19  
**Goal:** Make `flutter build apk --release` succeed without `--no-tree-shake-icons` by removing dynamic `IconData(...)` reconstruction from the subject icon system.

## Problem Statement

The current subject icon flow stores Material icon `codePoint` values in data, then reconstructs icons at runtime with:

```dart
IconData(iconCodepoint, fontFamily: 'MaterialIcons')
```

That pattern appears in:

- `lib/features/subjects/presentation/subject_icon_resolver.dart`
- `lib/features/subjects/edit_subjects/edit_subjects.dart`

Flutter release builds tree-shake icon fonts. Dynamic `IconData` reconstruction prevents Flutter from knowing which icons must be retained, so `flutter build apk --release` fails.

## Chosen Approach

Use **app-defined icon IDs with legacy fallback**.

Instead of persisting raw Material codepoints as the primary identity, the app will persist a small string ID such as:

- `calculator`
- `science`
- `book`
- `palette`
- `globe`

The app will map these IDs to compile-time constant `Icons.*` values. For older subject rows that still contain `icon_codepoint`, the app will translate known legacy codepoints to the new IDs and fall back safely to the default book icon for unknown values.

## Alternatives Considered

### 1. Keep dynamic icons and always build with `--no-tree-shake-icons`

**Pros**
- Fastest workaround
- No data-model changes

**Cons**
- Does not fix the root cause
- Easy for future builds to fail again if the flag is forgotten
- Produces larger APKs

### 2. Keep `icon_codepoint`, but whitelist known codepoints at render time

**Pros**
- Smaller code change than a new persisted field
- Avoids dynamic `IconData(...)` during rendering

**Cons**
- Data model remains tied to Flutter Material internals
- Harder to understand and maintain
- Still treats codepoints as the source of truth

### 3. Persist app-defined icon IDs and support legacy codepoints

**Pros**
- Fixes the release-build root cause
- Keeps UI icon resolution explicit and constant
- Decouples persisted data from Flutter icon implementation details
- Supports existing rows without immediate data migration

**Cons**
- Requires coordinated updates in model, DAO mapping, and subject forms

## Design

### Data Model

`SubjectRow` will gain a new string field, `iconId`, as the canonical icon identifier.

Rules:

- New writes always persist `icon_id`
- Existing `icon_codepoint` is still read for backward compatibility
- Existing `icon_codepoint` may continue to be written temporarily if the backend schema still expects it, but the app will no longer rely on it for rendering

### Icon Registry

Create a small subject-icon registry with:

- known icon IDs
- constant `IconData` values for each ID
- conversion helpers:
  - `iconId -> IconData`
  - legacy `iconCodepoint -> iconId`

This centralizes subject icon behavior and prevents dynamic icon construction from reappearing elsewhere.

### UI Flows

`AddSubjectsPage` and `EditSubjectsPage` should use icon IDs as selection state, or derive the selected `IconData` from a selected icon ID. The UI can still display `IconData`, but persistence should save the chosen icon ID.

For existing subject rows:

- prefer `iconId` if present
- otherwise derive from `iconCodepoint`
- otherwise use the default `book` icon

### Backward Compatibility

No immediate destructive migration is required.

Compatibility strategy:

1. read `icon_id` if available
2. else map `icon_codepoint` to one of the supported icon IDs
3. else fall back to `book`

This allows current data to keep rendering while all newly created or updated rows move onto the new representation.

### Error Handling

- Unknown `iconId` values fall back to the default subject icon
- Unknown legacy `iconCodepoint` values fall back to the default subject icon
- No runtime exception should be thrown for malformed subject icon data

### Testing

Primary verification should cover:

1. legacy rows with only `icon_codepoint`
2. new rows with `icon_id`
3. add/edit subject flows persisting the new value
4. release build success with plain:

```bash
flutter build apk --release
```

## Files Expected To Change

- `lib/features/subjects/data/models/subject_row.dart`
- `lib/features/subjects/presentation/subject_icon_resolver.dart`
- `lib/features/subjects/add_subjects/add_subjects.dart`
- `lib/features/subjects/edit_subjects/edit_subjects.dart`
- `lib/features/subjects/presentation/providers/subject_providers.dart`
- `lib/features/subjects/data/remote/supabase_subject_dao.dart` if mapping assumptions need adjustment
- `README.md` and `docs/submission/android-apk-submission.md` to remove the `--no-tree-shake-icons` workaround after verification

## Success Criteria

- Subject icons are resolved only from compile-time constant `Icons.*` values
- Existing subject data still renders without crashes
- New and edited subjects persist the new icon representation
- `flutter build apk --release` succeeds without extra icon flags
