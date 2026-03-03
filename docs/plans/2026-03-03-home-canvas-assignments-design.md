# Home Canvas Assignments Design

**Goal:** Replace the mock assignment cards on the Home page with real Canvas assignments fetched through Supabase Edge Functions, using the same Canvas integration pattern already established on the Subjects page.

## Current Project Context

- `lib/features/home/home_page.dart` still renders hard-coded `_todayTasks` and `_tomorrowTasks`.
- `lib/features/home/presentation/providers/home_tasks_provider.dart` currently exposes `homeTasksProvider` backed by the local `home_tasks` table, but the current Home UI does not use it.
- `lib/features/subjects/presentation/providers/subject_providers.dart` already demonstrates the Canvas integration pattern through `canvasCoursesProvider`.
- `supabase/functions/canvas-proxy/index.ts` currently proxies Canvas course data only.

## Chosen Approach

Add a dedicated Supabase Edge Function for Canvas assignments instead of expanding the existing course proxy. Flutter will call that function through a new home-specific remote data source, decode the response into a `CanvasAssignment` model, group assignments into `today` and `tomorrow`, and render them in the existing Home page card layout.

## Why This Approach

- Keeps Canvas credentials on the server side.
- Matches the architecture already used successfully on the Subjects page.
- Avoids coupling course fetching and assignment fetching into one overloaded function.
- Avoids premature sync-to-database complexity while still replacing mock data immediately.

## Data Flow

1. `HomePage` watches a new Riverpod provider for Canvas assignments.
2. The provider calls a home remote data source.
3. The remote data source invokes a new Supabase Edge Function such as `canvas-assignments-proxy`.
4. The Edge Function calls the Canvas assignments API and returns JSON.
5. Flutter decodes JSON into `CanvasAssignment` objects.
6. A mapper groups assignments into `today` and `tomorrow`.
7. `HomePage` renders section badges and `AssignmentsCard` widgets from those grouped lists.

## UI Design

- Keep the existing header and overall Home layout.
- Replace the hard-coded pending-assignment summary with a count derived from fetched Canvas assignments.
- Keep the `Today` and `Tomorrow` sections.
- Show the real task count badge for each section.
- Reuse `AssignmentsCard` so visual design stays unchanged.
- Show loading, empty, and error states inline where the assignment list normally appears.

## Mapping Rules

- `subject`: Canvas course name when available; otherwise use a short fallback such as `Canvas`.
- `title`: Canvas assignment name.
- `subtitle`: a short plain-text description when available; otherwise fallback to course name.
- `dueText`: formatted from `due_at` as `Due h:mm a`.
- `showDuePill`: `true` for assignments due today, `false` for tomorrow items to stay close to the current mock styling.
- Tag colors: generated deterministically from the subject string instead of hard-coded per subject.

## Filtering Rules

- Ignore assignments with `due_at == null`.
- Only keep assignments due between the start of today and the end of tomorrow in local time.
- Group by local date:
  - same day as now -> `today`
  - next day -> `tomorrow`

## Error Handling

- If the Edge Function returns a non-200 status, show a retry state on Home.
- If Canvas returns malformed JSON, throw a readable exception from the data source.
- Missing optional fields should never crash the UI; use fallbacks instead.

## Known Limitations

- This version reads live Canvas data each time instead of caching or syncing into the local assignments table.
- Description content from Canvas may contain HTML and should be stripped or simplified before rendering.
- Sectioning only covers `today` and `tomorrow`; later dates remain out of scope for this screen.
