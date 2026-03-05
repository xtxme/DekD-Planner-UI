# Assignments Card Simplification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify assignment cards so they show only subject and title while preserving full notes for the detail screen.

**Architecture:** Update the assignments feed mapper to stop populating list subtitles from local notes and Canvas descriptions. Then update the shared card widget to hide its subtitle block when the subtitle is empty so the list layout collapses cleanly without affecting the detail page's use of `detailsText`.

**Tech Stack:** Flutter, Riverpod, existing assignments feature widgets

---

### Task 1: Normalize Feed Items For Title-Only Cards

**Files:**
- Modify: `lib/features/assignments/presentation/providers/assignments_ui_mapper.dart`

**Step 1: Keep details separate from list subtitle**

Set `subtitle` to an empty string for local assignments while leaving `detailsText` mapped from local notes.

**Step 2: Keep Canvas subject name and remove preview text**

Map Canvas `subject` from `courseName` as the card chip label, keep `detailsText` from the stripped description, and set `subtitle` to an empty string.

### Task 2: Collapse Subtitle UI When Empty

**Files:**
- Modify: `lib/shared/widgets/assignments_card.dart`

**Step 1: Add conditional subtitle rendering**

Render the spacing and subtitle text only when `subtitle.trim().isNotEmpty`.

**Step 2: Preserve current card chrome**

Leave tag, due date, borders, and shadows unchanged.

### Task 3: Verify

**Files:**
- Modify: `lib/features/assignments/presentation/providers/assignments_ui_mapper.dart`
- Modify: `lib/shared/widgets/assignments_card.dart`

**Step 1: Format touched files**

Run `dart format` on the touched Dart files.

**Step 2: Analyze affected code**

Run `flutter analyze` for the touched files and fix any issues introduced by the change.
