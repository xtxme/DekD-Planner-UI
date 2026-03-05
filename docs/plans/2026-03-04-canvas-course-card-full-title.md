# Canvas Course Card Full Title Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the Canvas course import card so long course names display fully and the dismiss button sits on the same row as the import action.

**Architecture:** Keep all changes inside `_CanvasCourseCard` in `lib/features/subjects/subjects_page/subjects_page.dart`. Reuse the existing `course`, `isImported`, `isImporting`, and `canDismiss` values, adjusting only the presentation layout so the title wraps and the action controls move into a lower row.

**Tech Stack:** Flutter, Material widgets, existing `AppColors` theme constants

---

### Task 1: Let the course title expand naturally

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Locate the Canvas course title widget**

Confirm `_CanvasCourseCard` is the only place rendering the truncated `course.name` in the import list.

**Step 2: Remove the truncation rule**

Replace the title text configuration so `course.name` uses `softWrap: true` without `maxLines` or `TextOverflow.ellipsis`.

**Step 3: Keep the subtitle badge directly below**

Preserve the existing course code badge styling and spacing beneath the title.

### Task 2: Move the dismiss action beside import

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Remove the trailing action column**

Delete the separate right-side column that currently stacks the dismiss button above the import button.

**Step 2: Add an inline action row**

Render `_ImportButton` and, when `canDismiss` is true, `_DismissButton` in a horizontal row below the course code badge.

**Step 3: Preserve behavior**

Keep the existing `onImport`, `onDismiss`, `isImported`, and `isImporting` wiring unchanged.

### Task 3: Verify the widget compiles cleanly

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Run targeted analysis**

Run: `flutter analyze lib/features/subjects/subjects_page/subjects_page.dart`

Expected: no analyzer errors in the modified file.

**Step 2: Review the final diff**

Confirm the diff only changes the Canvas course card layout and leaves unrelated work in the dirty tree untouched.
