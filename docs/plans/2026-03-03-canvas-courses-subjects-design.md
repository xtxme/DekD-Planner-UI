# Canvas Courses to Subjects Design

**Goal:** Fetch real Canvas courses through the existing Supabase Edge Function and let the user import selected courses into the app's `subjects` table from the Subjects page.

## Current Project Context

- Supabase is initialized in `lib/core/supabase/supabase_initializer.dart`.
- The project already includes `supabase/functions/canvas-proxy/index.ts`.
- The Subjects page still renders mock data in `lib/features/subjects/subjects_page/subjects_page.dart`.
- Real app subjects already exist through `SubjectDao`, `SubjectRow`, and `subjectListProvider`.

## Chosen Approach

Use the existing `canvas-proxy` Supabase Edge Function as the only component that talks to Canvas. Flutter will call the Edge Function, decode the returned course list into a dedicated Canvas model, and render those courses in a separate "Canvas Courses" section on the Subjects page. Importing a course maps it into a `SubjectRow` and inserts it through the existing `SubjectDao`.

## Why This Approach

- Keeps `CANVAS_TOKEN` off the client-side request path.
- Reuses the app's existing Supabase data layer instead of introducing a second persistence flow.
- Avoids auto-importing unexpected courses.
- Keeps Canvas data clearly separated from local subjects until the user chooses to import.

## Data Flow

1. Flutter calls `canvas-proxy`.
2. `canvas-proxy` reads `CANVAS_BASE_URL` and `CANVAS_TOKEN` from Supabase function secrets.
3. `canvas-proxy` requests `GET /api/v1/courses` from Canvas.
4. Flutter decodes the JSON into a `CanvasCourse` model.
5. Subjects page renders:
   - `My Subjects` from Supabase
   - `Canvas Courses` from Canvas
6. User taps `Import`.
7. Flutter checks for duplicates with `SubjectDao.findByName`.
8. If not found, Flutter inserts a mapped `SubjectRow`.
9. Providers are invalidated to refresh both sections.

## UI Design

- Replace the mock subject list on the Subjects page with provider-driven data.
- Add a `My Subjects` section for current local subjects.
- Add a `Canvas Courses` section below it.
- Add a `Sync Canvas` action for re-fetching Canvas courses.
- Show per-course `Import` action.
- Hide or mark Canvas items that already exist locally.
- Show empty, loading, and error states for Canvas fetches.

## Import Rules

- `SubjectRow.name` = `course.name`
- `SubjectRow.code` = `course.course_code ?? ''`
- `SubjectRow.description` = `Imported from Canvas (course_id: <id>)`
- `SubjectRow.colorValue` = default app-safe color
- `SubjectRow.iconCodepoint` = default app-safe icon
- `SubjectRow.isArchived` = `false`

## Duplicate Handling

- Use `SubjectDao.findByName` before insert.
- If a subject with the same name already exists, do not insert again.
- UI should mark it as `Imported` or filter it out from the importable list.

## Error Handling

- `401` / `403`: token invalid or insufficient permission
- `500`: backend function or Canvas upstream failure
- Import failure should be isolated to the tapped course, not fail the entire list

## Known Limitations

- Duplicate detection by `name` is only a first-pass heuristic.
- A future schema revision should add stable external identifiers such as `external_source` and `external_id`.
