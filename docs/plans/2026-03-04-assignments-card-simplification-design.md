# Assignments Card Simplification Design

**Goal:** Make every assignment card show the real subject name and only the assignment title, without preview text under the title.

**Architecture:** Keep `AssignmentsFeedItem.detailsText` intact for the detail page, but stop using `subtitle` as a content preview for the list. Normalize the feed mapping so both local and Canvas items expose an empty `subtitle` for card rendering, then make the shared `AssignmentsCard` collapse the subtitle block when the string is empty.

**Scope:**
- Apply the visual simplification to all assignment cards in the assignments list.
- Preserve existing due-date styling and navigation behavior.
- Keep assignment detail notes/instructions unchanged.

**Data Flow:**
- Local assignments continue to map `subject`, `title`, and `detailsText` from local rows.
- Canvas assignments continue to map `subject` from `courseName` when present, with fallback only when the course name is missing.
- `subtitle` becomes an empty string for list rendering across both sources.
- `AssignmentsCard` conditionally renders the subtitle text only when it is non-empty.

**Error Handling:**
- If a Canvas course name is empty, keep the existing fallback subject label so the card still renders.
- If an assignment title is empty, preserve the current untitled fallback.
- If notes or Canvas descriptions are empty, the detail page still falls back to its existing placeholder text.

**Testing:**
- Verify local and Canvas cards render only the subject chip and title text.
- Verify Canvas cards show the real course name instead of a generic source label when available.
- Verify the detail page still shows notes/instructions from `detailsText`.
