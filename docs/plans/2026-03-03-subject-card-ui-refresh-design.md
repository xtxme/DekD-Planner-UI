# Subject Card UI Refresh Design

**Problem**

The subject card on the Subjects page truncates long subject names too aggressively, uses a soft shadow that makes the card edge look blurry, and renders the subject code as plain secondary text that does not feel visually distinct from the title.

**Goals**

- Show more of long subject names before truncation.
- Reduce the fuzzy card-edge look by tightening the card elevation treatment.
- Redesign the subject code into a light chip/badge that is clearly separated from the title.

**Non-goals**

- No data model changes.
- No navigation or interaction changes for the card tap behavior.
- No redesign of unrelated tabs or Canvas import actions.

**Design**

The existing subject list card in `lib/features/subjects/subjects_page/subjects_page.dart` will keep its current layout structure: icon on the left, content in the middle, arrow affordance on the right. The content block will be adjusted so the subject title can occupy more vertical space with a less aggressive truncation rule, while still preventing uncontrolled growth.

The card container styling will be refined by reducing the shadow blur/offset and leaning more on a subtle border so the silhouette reads cleanly against the page background instead of appearing washed out at the edges.

The subject code/subtitle will move from plain text into a compact badge directly beneath the title. The badge will use a soft background tint, rounded corners, internal horizontal padding, and a smaller text style than the title. This creates a clearer information hierarchy and makes the code visually distinct from the subject name.

**Data Flow**

The card will continue using the existing `subtitle` string derived from `_subjectSubtitle(subject)`. No provider or state changes are required.

**Error Handling**

No new error states are introduced. Empty subtitles will continue rendering as today unless the current widget logic already guarantees a fallback value.

**Testing**

This change is primarily visual. Verification will be done with targeted static analysis for the modified file and by checking the updated widget structure in code.
