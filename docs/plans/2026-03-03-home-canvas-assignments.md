# Home Canvas Assignments Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the Home page mock assignments with real Canvas assignments fetched through Supabase Edge Functions.

**Architecture:** Add a dedicated Canvas assignments Edge Function, then build a small Flutter data layer and Riverpod provider that map Canvas assignments into Home page view data grouped into `today` and `tomorrow`. Keep the existing Home UI structure and `AssignmentsCard`, but make all assignment content provider-driven.

**Tech Stack:** Flutter, Riverpod, Supabase Flutter, Supabase Edge Functions, Canvas REST API

---

### Task 1: Inspect the Canvas assignments API shape

**Files:**
- Read: `supabase/functions/canvas-proxy/index.ts`
- Read: Canvas API docs for assignments endpoint if you already have them locally or from your Canvas setup notes

**Step 1: Decide the exact Canvas endpoint**

- Prefer a single endpoint that can return upcoming assignments with due dates.
- A practical first version is course assignments with due dates included, or a dashboard/planner endpoint if your Canvas instance supports it.

**Step 2: Write down the minimal response fields you need**

- `id`
- `name`
- `due_at`
- `course_id`
- `course_name`
- `description`

**Step 3: Confirm how course names will be resolved**

- Best case: the endpoint already includes course name.
- Fallback: enrich assignments in the Edge Function by combining assignment data with course data.

### Task 2: Add a Supabase Edge Function for Canvas assignments

**Files:**
- Create: `supabase/functions/canvas-assignments-proxy/index.ts`
- Modify: `supabase/config.toml`

**Step 1: Copy the structure of the existing Canvas proxy**

- Reuse:
  - CORS headers
  - env lookup for `CANVAS_BASE_URL` and `CANVAS_TOKEN`
  - passthrough-style error handling

**Step 2: Point the fetch to the assignments endpoint**

- Build the URL with the query params your Canvas endpoint requires.
- Keep `per_page=100` if the endpoint supports it.

**Step 3: Normalize the returned JSON**

- Return only the fields the app needs.
- If Canvas returns HTML descriptions, you can leave them intact for now and sanitize in Flutter.

**Step 4: Register the new function**

- Add a new `[functions.canvas-assignments-proxy]` block to [supabase/config.toml](/Users/icy/flutter/DekD-Planner/DekD-Planner-UI/supabase/config.toml).

**Step 5: Verify locally**

Run:

```bash
supabase functions serve canvas-assignments-proxy --env-file supabase/.env.local
```

Expected:
- HTTP 200 with a JSON array of assignments

### Task 3: Add a Canvas assignment model in Flutter

**Files:**
- Create: `lib/features/home/data/models/canvas_assignment.dart`

**Step 1: Define the model fields**

```dart
class CanvasAssignment {
  const CanvasAssignment({
    required this.id,
    required this.name,
    required this.dueAt,
    required this.courseId,
    required this.courseName,
    required this.description,
  });

  final int id;
  final String name;
  final DateTime? dueAt;
  final int? courseId;
  final String courseName;
  final String description;
}
```

**Step 2: Add a `fromMap` factory**

- Parse values defensively.
- Convert `due_at` to local `DateTime?`.

**Step 3: Add small helpers only if they reduce UI noise**

- Example:
  - `bool get hasDueDate`
  - `String get safeCourseName`

### Task 4: Add a Home remote data source for Canvas assignments

**Files:**
- Create: `lib/features/home/data/remote/canvas_assignment_remote_data_source.dart`

**Step 1: Reuse the shared Supabase client**

- Mirror the pattern from [canvas_course_remote_data_source.dart](/Users/icy/flutter/DekD-Planner/DekD-Planner-UI/lib/features/subjects/data/remote/canvas_course_remote_data_source.dart).

**Step 2: Add `fetchAssignments()`**

```dart
final response = await _client.functions.invoke('canvas-assignments-proxy');
```

**Step 3: Validate the response shape**

- Throw if status is 400+
- Throw if `response.data` is not a `List`

**Step 4: Decode JSON into models**

- Map every item to `CanvasAssignment.fromMap(...)`
- Filter out rows with null `dueAt`

### Task 5: Add Riverpod providers and view-model mapping

**Files:**
- Modify: `lib/features/home/presentation/providers/home_tasks_provider.dart`
- Read: `lib/features/subjects/presentation/providers/subject_providers.dart`

**Step 1: Add a provider for the remote data source**

```dart
final canvasAssignmentRemoteDataSourceProvider =
    Provider<CanvasAssignmentRemoteDataSource>(...);
```

**Step 2: Add a provider for raw Canvas assignments**

```dart
final homeCanvasAssignmentsProvider =
    FutureProvider<List<CanvasAssignment>>((ref) async { ... });
```

**Step 3: Add grouped Home view data**

- Create a small typed result, for example:

```dart
class HomeAssignmentSections {
  const HomeAssignmentSections({
    required this.today,
    required this.tomorrow,
  });

  final List<CanvasAssignment> today;
  final List<CanvasAssignment> tomorrow;
}
```

**Step 4: Filter by local date**

- `today`: due date is the same local calendar day as `DateTime.now()`
- `tomorrow`: due date is exactly one day after today

**Step 5: Keep the provider logic pure**

- No widget color code in the page itself if you can avoid it.
- Put mapping helpers near the provider or in a dedicated helper file if it grows.

### Task 6: Add UI helpers for formatting and tag colors

**Files:**
- Create: `lib/features/home/presentation/home_assignment_ui_mapper.dart`

**Step 1: Add deterministic subject color generation**

- Input: `courseName`
- Output:
  - `tagBg`
  - `tagColor`

**Step 2: Add due text formatting**

- Format `dueAt` into `Due h:mm a`

**Step 3: Add subtitle cleanup**

- Strip HTML tags from Canvas description if present.
- Fallback order:
  - cleaned description
  - course name
  - `Canvas assignment`

**Step 4: Add a mapper into a UI-ready object**

- Either map directly into `TaskItem`
- Or create a new `HomeAssignmentCardData` if you want to avoid overloading the mock-oriented `TaskItem`

### Task 7: Replace mock data usage in HomePage

**Files:**
- Modify: `lib/features/home/home_page.dart`
- Read: `lib/shared/widgets/assignments_card.dart`

**Step 1: Remove the hard-coded lists**

- Delete:
  - `_todayTasks`
  - `_tomorrowTasks`

**Step 2: Watch the new provider**

```dart
final assignmentsAsync = ref.watch(homeCanvasAssignmentsSectionsProvider);
```

**Step 3: Replace the summary text**

- Compute the total pending count from `today.length + tomorrow.length`
- Example output:
  - `You have 5 assignments pending this week.`
- If you only load today/tomorrow data, change the wording so it stays accurate.

**Step 4: Render async states**

- `loading`: show a compact loading placeholder
- `error`: show a retry button that invalidates the provider
- `data`: render the grouped sections

**Step 5: Render section badges from real counts**

- `Today` badge: `${today.length} Tasks`
- `Tomorrow` badge only if you want visual parity; otherwise keep the current section title only

### Task 8: Add explicit empty and error widgets for the Home page

**Files:**
- Modify: `lib/features/home/home_page.dart`

**Step 1: Add an empty state for no due assignments**

- Message:
  - `No assignments due today or tomorrow.`

**Step 2: Add an error state**

- Title:
  - `Canvas sync failed`
- Action:
  - `Try again`

**Step 3: Make retry invalidate the assignments provider**

```dart
ref.invalidate(homeCanvasAssignmentsProvider);
ref.invalidate(homeCanvasAssignmentsSectionsProvider);
```

### Task 9: Verify behavior manually

**Files:**
- Read: `supabase/.env.local`
- Read: [home_page.dart](/Users/icy/flutter/DekD-Planner/DekD-Planner-UI/lib/features/home/home_page.dart)

**Step 1: Start local Supabase functions**

Run:

```bash
supabase functions serve canvas-assignments-proxy --env-file supabase/.env.local
```

Expected:
- Function starts without missing secret errors

**Step 2: Run the app and open Home**

Expected:
- Header still renders
- Mock cards are gone
- Today/Tomorrow sections are populated from Canvas if data exists

**Step 3: Test three states**

- Canvas returns assignments due today
- Canvas returns assignments due tomorrow
- Canvas returns error or empty list

**Step 4: Check date grouping carefully**

- Confirm assignments near midnight are grouped by local timezone as intended

### Task 10: Optional cleanup after the first working version

**Files:**
- Modify: `lib/features/home/models/task_item.dart`
- Modify: `lib/features/home/presentation/providers/home_tasks_provider.dart`

**Step 1: Remove or repurpose unused mock-only types**

- If `TaskItem` becomes redundant, either delete it or rename it into a real UI model.

**Step 2: Separate local home tasks from Canvas tasks if both must coexist later**

- Keep this out of the first version unless requirements change.
