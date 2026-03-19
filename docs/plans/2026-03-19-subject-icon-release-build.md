# Subject Icon Release Build Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove dynamic subject icon reconstruction so `flutter build apk --release` succeeds without `--no-tree-shake-icons`, while keeping existing subject data usable.

**Architecture:** Introduce a small app-owned subject icon registry keyed by stable string IDs, persist the new `icon_id` field for all new and updated subjects, and keep a compatibility path that maps legacy `icon_codepoint` values to supported icon IDs. UI code will resolve icons only from constant `Icons.*` references.

**Tech Stack:** Flutter, Dart, Supabase, existing subject feature modules, Flutter test.

---

### Task 1: Add tests for icon registry and legacy fallback

**Files:**
- Modify: `test/features/subjects/presentation/subject_icon_resolver_test.dart`
- Modify: `test/features/subjects/data/models/subject_row_test.dart`

**Step 1: Write failing resolver tests**

Update `test/features/subjects/presentation/subject_icon_resolver_test.dart` to assert:

```dart
import 'package:flutter/material.dart';
import 'package:my_first_app/features/subjects/presentation/subject_icon_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('resolveSubjectIcon', () {
    test('uses icon id when present', () {
      final icon = resolveSubjectIcon(iconId: 'science', iconCodepoint: 0);

      expect(icon, Icons.science_rounded);
    });

    test('maps legacy codepoint to supported icon', () {
      final icon = resolveSubjectIcon(
        iconId: null,
        iconCodepoint: Icons.palette_rounded.codePoint,
      );

      expect(icon, Icons.palette_rounded);
    });

    test('falls back to default icon for unknown values', () {
      final icon = resolveSubjectIcon(iconId: 'unknown', iconCodepoint: 123456);

      expect(icon, Icons.menu_book_rounded);
    });
  });
}
```

**Step 2: Write failing model tests**

Update `test/features/subjects/data/models/subject_row_test.dart` to cover:

```dart
test('writes icon_id into insert and update maps', () {
  const row = SubjectRow(
    name: 'Imported subject',
    code: 'SUBJ101',
    description: 'Imported from Canvas',
    colorValue: 0xFFE2D4C7,
    iconId: 'science',
    iconCodepoint: Icons.science_rounded.codePoint,
    isArchived: false,
  );

  expect(row.toInsertMap(userId: 'user-1')['icon_id'], 'science');
  expect(row.toUpdateMap()['icon_id'], 'science');
});

test('prefers icon_id when reading from map', () {
  final row = SubjectRow.fromMap({
    'name': 'Imported subject',
    'code': 'SUBJ101',
    'description': 'Imported from Canvas',
    'color_value': -1911609,
    'icon_id': 'palette',
    'icon_codepoint': Icons.science_rounded.codePoint,
    'is_archived': false,
  });

  expect(row.iconId, 'palette');
});
```

**Step 3: Run the focused tests to verify failure**

Run:

```bash
dart test test/features/subjects/presentation/subject_icon_resolver_test.dart test/features/subjects/data/models/subject_row_test.dart
```

Expected: FAIL because the new resolver API and `iconId` field do not exist yet.

**Step 4: Commit the failing-test checkpoint**

Run:

```bash
git add test/features/subjects/presentation/subject_icon_resolver_test.dart test/features/subjects/data/models/subject_row_test.dart
git commit -m "test: cover subject icon id compatibility"
```

### Task 2: Introduce app-defined icon IDs and compatibility mapping

**Files:**
- Modify: `lib/features/subjects/presentation/subject_icon_resolver.dart`
- Modify: `lib/features/subjects/data/models/subject_row.dart`

**Step 1: Add the icon registry**

Replace the current resolver with a small constant registry:

```dart
import 'package:flutter/material.dart';

const String kDefaultSubjectIconId = 'book';

const Map<String, IconData> kSubjectIcons = {
  'calculator': Icons.calculate_rounded,
  'science': Icons.science_rounded,
  'book': Icons.menu_book_rounded,
  'palette': Icons.palette_rounded,
  'globe': Icons.public_rounded,
};

IconData resolveSubjectIcon({required String? iconId, required int iconCodepoint}) {
  final resolvedId = normalizeSubjectIconId(iconId, iconCodepoint: iconCodepoint);
  return kSubjectIcons[resolvedId] ?? kSubjectIcons[kDefaultSubjectIconId]!;
}
```

Add helpers for:

- `normalizeSubjectIconId(String? iconId, {required int iconCodepoint})`
- `legacyCodepointToSubjectIconId(int iconCodepoint)`

Map these legacy codepoints:

```dart
Icons.calculate_rounded.codePoint -> 'calculator'
Icons.science_rounded.codePoint -> 'science'
Icons.menu_book_rounded.codePoint -> 'book'
Icons.palette_rounded.codePoint -> 'palette'
Icons.public_rounded.codePoint -> 'globe'
```

**Step 2: Add canonical `iconId` to `SubjectRow`**

Update `lib/features/subjects/data/models/subject_row.dart`:

```dart
const SubjectRow({
  this.id,
  required this.name,
  required this.code,
  required this.description,
  required this.colorValue,
  required this.iconId,
  required this.iconCodepoint,
  required this.isArchived,
});

final String iconId;
```

Update `copyWith`, `toInsertMap`, `toUpdateMap`, and `fromMap` so:

- `icon_id` is written on inserts and updates
- `fromMap` reads `icon_id` first
- missing `icon_id` falls back to the normalized legacy mapping

**Step 3: Run focused tests**

Run:

```bash
dart test test/features/subjects/presentation/subject_icon_resolver_test.dart test/features/subjects/data/models/subject_row_test.dart
```

Expected: PASS

**Step 4: Commit the compatibility layer**

Run:

```bash
git add lib/features/subjects/presentation/subject_icon_resolver.dart lib/features/subjects/data/models/subject_row.dart test/features/subjects/presentation/subject_icon_resolver_test.dart test/features/subjects/data/models/subject_row_test.dart
git commit -m "feat: add subject icon id compatibility layer"
```

### Task 3: Update subject creation and editing flows to persist icon IDs

**Files:**
- Modify: `lib/features/subjects/add_subjects/add_subjects.dart`
- Modify: `lib/features/subjects/edit_subjects/edit_subjects.dart`
- Modify: `lib/features/subjects/presentation/providers/subject_providers.dart`

**Step 1: Replace selection state with icon IDs**

In `add_subjects.dart` and `edit_subjects.dart`, keep the visual choice lists as constant `IconData` values, but store the selected choice as a string ID:

```dart
String _selectedIconId = 'calculator';

IconData get _selectedIcon => kSubjectIcons[_selectedIconId]!;
```

Add a helper map for UI choice conversion:

```dart
String subjectIconIdForIcon(IconData icon)
```

**Step 2: Initialize edit screens using compatibility mapping**

In `edit_subjects.dart`, initialize selection with:

```dart
_selectedIconId = normalizeSubjectIconId(
  widget.subject.iconId,
  iconCodepoint: widget.subject.iconCodepoint,
);
```

Do not construct `IconData(...)` dynamically.

**Step 3: Persist `iconId` when saving**

Update subject creation and editing to save:

```dart
SubjectRow(
  ...
  iconId: _selectedIconId,
  iconCodepoint: kSubjectIcons[_selectedIconId]!.codePoint,
  ...
)
```

Update the Canvas import default in `subject_providers.dart` to include:

```dart
iconId: 'book',
iconCodepoint: Icons.menu_book_rounded.codePoint,
```

**Step 4: Run focused widget-free tests or static checks**

Run:

```bash
dart test test/features/subjects/presentation/subject_icon_resolver_test.dart test/features/subjects/data/models/subject_row_test.dart
```

Expected: PASS

**Step 5: Commit the UI persistence changes**

Run:

```bash
git add lib/features/subjects/add_subjects/add_subjects.dart lib/features/subjects/edit_subjects/edit_subjects.dart lib/features/subjects/presentation/providers/subject_providers.dart
git commit -m "refactor: persist subject icon ids in forms"
```

### Task 4: Add backend schema support for `icon_id`

**Files:**
- Create: `supabase/migrations/003_subject_icon_id.sql`

**Step 1: Add the new column**

Create migration:

```sql
alter table public.subjects
  add column if not exists icon_id text;
```

**Step 2: Backfill known rows**

In the same migration, backfill supported legacy values:

```sql
update public.subjects
set icon_id = case icon_codepoint
  when 0 then 'book'
  when 62973 then 'calculator'
  when 983343 then 'science'
  when 63668 then 'book'
  when 983105 then 'palette'
  when 983238 then 'globe'
  else 'book'
end
where icon_id is null;
```

**Step 3: Add a default constraint for future rows**

Append:

```sql
alter table public.subjects
  alter column icon_id set default 'book';
```

**Step 4: Review the migration**

Run:

```bash
sed -n '1,200p' supabase/migrations/003_subject_icon_id.sql
```

Expected: The migration adds `icon_id`, backfills known rows, and sets a default.

**Step 5: Commit the migration**

Run:

```bash
git add supabase/migrations/003_subject_icon_id.sql
git commit -m "db: add subject icon ids"
```

### Task 5: Verify release build and remove workaround docs

**Files:**
- Modify: `README.md`
- Modify: `docs/submission/android-apk-submission.md`

**Step 1: Run full subject tests**

Run:

```bash
dart test test/features/subjects/presentation/subject_icon_resolver_test.dart test/features/subjects/data/models/subject_row_test.dart
```

Expected: PASS

**Step 2: Build release APK without the workaround**

Run:

```bash
flutter build apk --release
```

Expected: PASS without the `--no-tree-shake-icons` flag.

**Step 3: Verify artifact exists**

Run:

```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

Expected: The APK file exists and has a non-zero size.

**Step 4: Remove workaround language from docs**

Update `README.md` and `docs/submission/android-apk-submission.md` so the build command is:

```bash
flutter build apk --release
```

Remove notes that `--no-tree-shake-icons` is required. Keep any still-true release-signing caveats.

**Step 5: Commit final verification/docs**

Run:

```bash
git add README.md docs/submission/android-apk-submission.md
git commit -m "docs: update release build instructions"
```
