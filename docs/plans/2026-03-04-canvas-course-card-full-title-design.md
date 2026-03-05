# Canvas Course Card Full Title Design

**Problem**

The Canvas course import card truncates long course names with an ellipsis and places the dismiss action in a separate top-right slot, which wastes vertical space and hides the full course name.

**Goals**

- Show the full course name by allowing the card to grow vertically.
- Place the dismiss `X` button on the same row as the `Import` or `Imported` button.
- Keep the existing import and dismiss behavior unchanged.

**Non-goals**

- No provider, model, or import logic changes.
- No changes to the local subject list card layout.
- No redesign of unrelated page sections.

**Design**

Update `_CanvasCourseCard` in `lib/features/subjects/subjects_page/subjects_page.dart` so the content column owns the full responsive layout. The course name text will remove its line cap and ellipsis, allowing natural wrapping. The course code badge remains directly beneath the title.

The action controls will move below the badge into a single horizontal row. The `Import` or `Imported` button stays first, and the dismiss button appears beside it when dismissal is allowed. This keeps both actions visually grouped while freeing horizontal room for the title above.

**Data Flow**

The widget will continue reading `course.name`, `course.courseCode`, `isImported`, and `isImporting` exactly as it does now. No state or mapping changes are required.

**Error Handling**

No new error states are introduced. Importing continues to disable or hide actions using the existing `canDismiss` and button state logic.

**Testing**

Verification will be done with targeted static analysis for `lib/features/subjects/subjects_page/subjects_page.dart` and by reviewing the resulting widget diff to ensure only the Canvas course card layout changed.
