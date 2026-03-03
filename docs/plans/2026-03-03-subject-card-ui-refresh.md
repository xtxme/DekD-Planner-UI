# Subject Card UI Refresh Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the subject list card so long titles remain readable, the card edge shadow is cleaner, and the subject code is displayed as a distinct badge.

**Architecture:** Keep the existing `_SubjectListCard` widget in `lib/features/subjects/subjects_page/subjects_page.dart` and adjust only its presentation-layer layout and decoration. Reuse the existing `subtitle` value as badge content so no provider, model, or page-level state changes are needed.

**Tech Stack:** Flutter, Material widgets, existing `AppColors` theme constants

---

### Task 1: Refine the subject card layout

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Inspect the existing `_SubjectListCard` title and subtitle layout**

Confirm where `subject.name` and `subtitle` are rendered so only the local subject card changes.

**Step 2: Expand title capacity**

Adjust the `Text` for `subject.name` to allow more visible content before truncation while keeping the row layout stable.

**Step 3: Convert the subtitle into a badge**

Wrap the subtitle text in a rounded container with light background tint, compact padding, and smaller typography so it reads as metadata rather than body text.

**Step 4: Keep tap affordance intact**

Preserve the trailing arrow and current `InkWell` interaction behavior.

### Task 2: Tighten the card edge styling

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Reduce shadow softness**

Lower the blur radius and vertical offset of the card shadow so the edge looks cleaner.

**Step 2: Strengthen the silhouette with the existing border**

Retain a subtle border and ensure the card still separates from the page background without a heavy glow.

**Step 3: Recheck spacing**

Adjust vertical spacing around the title and badge if needed so the card still feels balanced.

### Task 3: Verify the widget compiles cleanly

**Files:**
- Modify: `lib/features/subjects/subjects_page/subjects_page.dart`

**Step 1: Run targeted analysis**

Run: `flutter analyze lib/features/subjects/subjects_page/subjects_page.dart`

Expected: no analyzer errors in the modified file.

**Step 2: Review the final diff**

Check that only the intended subject card presentation changed and unrelated staged work remains untouched.
