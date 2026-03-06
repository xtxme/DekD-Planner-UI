# Subject Details Real Data Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace mocked subject-detail assignments with real merged local + Canvas assignments for the selected subject.

**Architecture:** SubjectsDetailPage consumes existing assignment providers, maps local/canvas records into one UI model, filters by selected subject, then splits into Upcoming/Completed tabs.

**Tech Stack:** Flutter, Riverpod, existing assignments/home providers.

---

### Task 1: Build subject-detail assignment data mapping

**Files:**
- Modify: `lib/features/subjects/subjects_detail/subjects_detail.dart`

**Step 1: Remove mock assignment source**
- Delete static `_allAssignments` and `_visibleAssignments` mock logic.

**Step 2: Add real data view model**
- Add a private UI model for subject detail cards and status enum mapping.

**Step 3: Load providers in build**
- Read `assignmentListProvider` and `canvasAssignmentsWithUserProvider`.
- Combine to unified list and filter by `widget.subject.name`.

**Step 4: Split tabs**
- Upcoming = non-completed
- Completed = completed

**Step 5: Render cards using mapped list**
- Keep same card visual style; drive title, due text, status, icon from real data.

### Task 2: Verify behavior and quality gates

**Files:**
- Modify: `lib/features/subjects/subjects_detail/subjects_detail.dart`

**Step 1: Run static analysis**
Run: `flutter analyze lib/features/subjects/subjects_detail/subjects_detail.dart`
Expected: No issues found.

**Step 2: Manual verification checklist**
- Open Subjects page
- Tap a subject card
- Verify only that subject's assignments show
- Verify upcoming/completed tabs reflect real statuses
