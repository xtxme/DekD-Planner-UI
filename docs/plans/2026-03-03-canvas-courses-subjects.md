# Canvas Courses to Subjects Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fetch real Canvas course data through the existing Supabase Edge Function and let users import Canvas courses into the app's Subjects page.

**Architecture:** The Supabase Edge Function remains the only component that talks to Canvas. Flutter adds a small Canvas data layer, provider layer, and Subjects page UI section for sync/import, while reusing the existing `SubjectDao` and `subjects` table for persistence.

**Tech Stack:** Flutter, Riverpod, Supabase Flutter, Supabase Edge Functions, Canvas REST API

---

### Task 1: Update the Supabase Edge Function to return Canvas courses

**Files:**
- Modify: `supabase/functions/canvas-proxy/index.ts`

**Step 1: Replace the hard-coded `/api/v1/users/self` call**

- Change the fetch target to `/api/v1/courses?per_page=100`.
- Filter server-side later only if needed; first ship the raw course list.

**Step 2: Preserve status codes and JSON response**

- Keep passthrough behavior so Flutter can inspect upstream failures.
- Keep CORS headers unchanged.

**Step 3: Add lightweight request-shape support**

- Optionally allow `req.method == "POST"` with JSON body later, but keep the first version simple if not needed.

**Step 4: Deploy and verify manually**

Run:

```bash
supabase functions deploy canvas-proxy
```

Then verify with:

```bash
supabase functions serve canvas-proxy --env-file supabase/.env.local
```

Expected:
- HTTP 200 with a JSON array of Canvas course objects.

**Step 5: Commit**

```bash
git add supabase/functions/canvas-proxy/index.ts
git commit -m "feat: return canvas courses from proxy"
```

### Task 2: Add a Canvas course model in Flutter

**Files:**
- Create: `lib/features/subjects/data/models/canvas_course.dart`

**Step 1: Create a minimal model**

- Add fields:
  - `id`
  - `name`
  - `courseCode`
  - `sisCourseId`

**Step 2: Add `fromMap` parsing**

- Parse from Canvas JSON safely with null-aware defaults.

**Step 3: Add a helper for import description**

- Example:

```dart
String get importDescription => 'Imported from Canvas (course_id: $id)';
```

**Step 4: Commit**

```bash
git add lib/features/subjects/data/models/canvas_course.dart
git commit -m "feat: add canvas course model"
```

### Task 3: Add a Flutter data source for the Edge Function

**Files:**
- Create: `lib/features/subjects/data/remote/canvas_course_remote_data_source.dart`
- Modify: `lib/core/supabase/supabase_client_provider.dart`

**Step 1: Read the existing Supabase client provider**

- Reuse the existing client instead of creating another instance.

**Step 2: Create a small remote data source**

- Add `fetchCourses()` that calls:

```dart
await client.functions.invoke('canvas-proxy');
```

- Decode the returned array into `List<CanvasCourse>`.

**Step 3: Fail loudly on non-array responses**

- Throw a readable exception if the function returns unexpected JSON.

**Step 4: Commit**

```bash
git add lib/features/subjects/data/remote/canvas_course_remote_data_source.dart lib/core/supabase/supabase_client_provider.dart
git commit -m "feat: add canvas course remote data source"
```

### Task 4: Add Riverpod providers for fetch and import

**Files:**
- Modify: `lib/features/subjects/presentation/providers/subject_providers.dart`

**Step 1: Add a provider for the remote data source**

- Expose the new Canvas data source through `Provider`.

**Step 2: Add a Canvas courses provider**

- Use `FutureProvider<List<CanvasCourse>>` for the first version to match the current codebase style.

**Step 3: Add an import action provider**

- Prefer `Provider` exposing a small service method or callback-style class.
- The import method should:
  - call `findByName`
  - insert mapped `SubjectRow` if not found
  - invalidate `subjectListProvider`
  - invalidate `canvasCoursesProvider`

**Step 4: Commit**

```bash
git add lib/features/subjects/presentation/providers/subject_providers.dart
git commit -m "feat: add canvas courses providers"
```

### Task 5: Replace mock subjects on the Subjects page

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`
- Read: `lib/features/subjects/subjects_page/widgets/grid.dart`
- Read: `lib/features/subjects/subjects_page/widgets/header.dart`

**Step 1: Remove the static `_subjects` mock list**

- Stop relying on hard-coded `SubjectGridItem` data as the source of truth.

**Step 2: Watch both data sources**

- `subjectListProvider`
- `canvasCoursesProvider`

**Step 3: Map local subjects into the existing grid widget**

- Convert each `SubjectRow` into `SubjectGridItem`.

**Step 4: Add a second section for Canvas courses**

- Use a simple column/list if the current grid widget is too local-subject-specific.
- Keep the first version functionally clear rather than over-designed.

**Step 5: Add a `Sync Canvas` action**

- Trigger `ref.invalidate(canvasCoursesProvider)`.

**Step 6: Add loading, error, and empty states**

- Local subjects state
- Canvas courses state

**Step 7: Commit**

```bash
git add lib/features/subjects/subjects_page/subjects_page.dart
git commit -m "feat: show canvas courses on subjects page"
```

### Task 6: Add per-course import UI

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Add an import button for each Canvas course**

- Button label:
  - `Import` when not yet present
  - `Imported` when already in local subjects

**Step 2: Wire the button to the import provider/service**

- Use `ref.read(...)` inside the tap handler.

**Step 3: Show user feedback**

- Success: `SnackBar` with course name
- Failure: `SnackBar` with readable error

**Step 4: Prevent duplicate taps while importing**

- Track a local `Set<String>` of importing course IDs in page state, or add a dedicated provider if needed.

**Step 5: Commit**

```bash
git add lib/features/subjects/subjects_page/subjects_page.dart
git commit -m "feat: add canvas course import actions"
```

### Task 7: Add a small widget test for the Subjects page states

**Files:**
- Create: `test/features/subjects/subjects_page_test.dart`

**Step 1: Write a test for Canvas loading/error/content states**

- Override providers in a `ProviderScope`.
- Assert the page renders the expected section labels or error text.

**Step 2: Write a test for imported-state labeling**

- Provide one local subject and one matching Canvas course.
- Assert the matching course renders as already imported.

**Step 3: Run the targeted test**

Run:

```bash
flutter test test/features/subjects/subjects_page_test.dart
```

Expected:
- PASS

**Step 4: Commit**

```bash
git add test/features/subjects/subjects_page_test.dart
git commit -m "test: cover subjects canvas sync states"
```

### Task 8: End-to-end manual verification

**Files:**
- Read: `.env`
- Read: `supabase/config.toml`

**Step 1: Confirm Supabase env values are set in the right place**

- App `.env` is for Flutter runtime values.
- Supabase function secrets must be set for the Edge Function runtime.

**Step 2: Run the app and verify the full flow**

Run:

```bash
flutter run
```

Manual checks:
- Subjects page loads local subjects
- Sync Canvas fetches real courses
- Import inserts a selected course
- Imported course appears in local subjects
- Imported course is no longer offered as importable

**Step 3: Final commit**

```bash
git add .
git commit -m "feat: integrate canvas courses into subjects page"
```
