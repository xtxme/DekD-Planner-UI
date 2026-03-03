# Subject Search And Badge Refinement Design

**Problem**

The Subjects search field still uses the old placeholder copy and does not provide an inline clear action. The subject metadata badge is improved, but course codes that contain multiple meaningful parts are still shown as one string instead of distinct visual tokens.

**Goals**

- Change the search placeholder to `search subjects, codes`.
- Add a clear button inside the search field that appears only when text is present.
- Keep search state behavior unchanged for filtering.
- Refine subject metadata badges so parseable code segments can render as separate chips.

**Non-goals**

- No provider or filtering logic changes beyond keeping the existing query update flow.
- No redesign of Canvas course cards in this pass.

**Design**

The search field in `lib/features/subjects/subjects_page/widgets/header.dart` will become locally stateful so it can manage a `TextEditingController` and show a trailing clear icon only when the field is non-empty. Clearing will reset the controller text and immediately call the existing `onQueryChanged('')` callback, preserving current page-level filtering behavior.

The placeholder text will be updated to the requested lowercase copy: `search subjects, codes`.

In `lib/features/subjects/subjects_page/subjects_page.dart`, the subject card badge renderer will parse the existing `subtitle` string into up to two display parts using simple delimiters already present in subject codes, such as `-`. If parsing produces two meaningful segments, the card will show two adjacent chips with differentiated tint/weight. If parsing is not reliable, the existing single-chip fallback remains.

**Testing**

Verification will be limited to targeted `flutter analyze` runs for the modified files and review of the resulting widget diff.
