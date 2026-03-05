# Assignment Detail Source-Aware Design

**Goal:** Open assignment details from the list using the actual tapped item, and render source-specific actions for local versus Canvas assignments.

**Architecture:** The assignments list will navigate with `AssignmentsFeedItem` instead of relying on shared draft state. The detail page will read the item directly, derive a local `AssignmentDraft` only when the source is local, and conditionally enable actions based on `AssignmentFeedSource`.

**Scope:**
- Keep the existing visual design of the detail page.
- Local assignments continue to support edit and delete.
- Canvas assignments are view-only for edit/delete in this round.
- No Canvas overlay persistence in this round.

**Data Flow:**
- `AssignmentsPage` passes the tapped `AssignmentsFeedItem` to `AssignmentsDetailPage`.
- `AssignmentsDetailPage` renders title, due date, subject, notes, and status from that item.
- For `local` items, `Edit` navigates to `EditAssignmentsPage` with a derived `AssignmentDraft`.
- For `canvas` items, `Edit` and `Delete` are hidden/disabled.

**Error Handling:**
- If a local item is missing required local identifiers, the page still renders read-only data from the feed item.
- If notes/subtitle are empty, show fallback empty text rather than crashing.

**Testing:**
- Verify tapping a local card opens detail with local data and enabled edit/delete.
- Verify tapping a Canvas card opens detail with Canvas data and disabled edit/delete.
- Verify the page still renders when item notes are empty.
