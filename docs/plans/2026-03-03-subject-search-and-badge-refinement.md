# Subject Search And Badge Refinement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add an inline clear action to the Subjects search field, update its placeholder copy, and split parseable subject-code metadata into separate chips.

**Architecture:** Keep the existing query callback contract from `SubjectsHeader` to `SubjectsPage`, but make the header locally stateful so it can manage text-entry UI concerns. Keep the subject-card data source unchanged and add a small presentation helper in `subjects_page.dart` to derive one or two badge labels from the existing subtitle string.

**Tech Stack:** Flutter, Material widgets, existing `AppColors` theme constants

---

### Task 1: Update the Subjects search field UI

**Files:**
- Modify: `lib/features/subjects/subjects_page/widgets/header.dart`

**Step 1: Add local text controller state**

Convert `SubjectsHeader` from `StatelessWidget` to `StatefulWidget` and manage a `TextEditingController` plus a listener for suffix-icon visibility.

**Step 2: Add clear affordance**

Render a trailing clear icon only when the field contains text. On tap, clear the controller and call `onQueryChanged('')`.

**Step 3: Update placeholder copy**

Change the hint text to `search subjects, codes`.

### Task 2: Refine subject metadata badge rendering

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Add badge parsing helper**

Create a small helper that attempts to split the subtitle into meaningful parts, preferring a two-part result only when both sides are non-empty.

**Step 2: Render one or two chips**

Replace the single badge block with a wrap/row that renders two differentiated chips when parsing succeeds, otherwise keep a single fallback chip.

**Step 3: Preserve current layout balance**

Keep the existing title spacing and card interaction intact while adjusting chip styling for stronger contrast.

### Task 3: Verify the updated widgets

**Files:**
- Modify: `lib/features/subjects/subjects_page/widgets/header.dart`
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Run targeted analysis**

Run: `flutter analyze lib/features/subjects/subjects_page/widgets/header.dart lib/features/subjects/subjects_page/subjects_page.dart`

Expected: no analyzer errors in the modified files.

**Step 2: Review the final diff**

Confirm the changes are limited to the approved search field and badge refinements.
