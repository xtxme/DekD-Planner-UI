# Assignment Detail Source-Aware Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Open assignment details from the tapped assignment card and show source-aware actions for local and Canvas items.

**Architecture:** The list page will pass `AssignmentsFeedItem` into the detail route. The detail page will render from this feed model directly and derive edit behavior only for local items, leaving Canvas items read-only for edit/delete.

**Tech Stack:** Flutter, Riverpod, existing assignments feature widgets

---

### Task 1: Extend Feed Model For Detail Routing

**Files:**
- Modify: `lib/features/assignments/models/assignments_feed_item.dart`
- Modify: `lib/features/assignments/presentation/providers/assignments_ui_mapper.dart`

**Step 1: Add detail fields**

Add local/source identifiers and note payload needed by the detail page.

**Step 2: Populate them in the mapper**

Map local rows and Canvas assignments into the richer feed model.

### Task 2: Route With Feed Item

**Files:**
- Modify: `lib/features/assignments/assignments_page/assignments_page.dart`
- Modify: `lib/features/assignments/assignments_detail/assignments_detail.dart`

**Step 1: Pass item into detail page**

Replace the hardcoded detail route with `AssignmentsDetailPage(item: item, withNavBar: false)`.

**Step 2: Render detail from item**

Use the passed item to build due text, notes, subject, and status.

### Task 3: Source-Aware Actions

**Files:**
- Modify: `lib/features/assignments/assignments_detail/assignments_detail.dart`
- Modify: `lib/features/assignments/assignments_detail/widgets/assignment_detail_action_buttons.dart`

**Step 1: Gate local actions**

Show edit/delete only for local items.

**Step 2: Keep complete available**

Leave complete visible for both sources in this round, but do not add persistence for Canvas yet.

### Task 4: Verify

**Files:**
- Modify: `lib/features/assignments/assignments_page/assignments_page.dart`
- Modify: `lib/features/assignments/assignments_detail/assignments_detail.dart`

**Step 1: Format touched files**

Run `dart format` on touched files.

**Step 2: Analyze touched files**

Run `flutter analyze` on touched files and fix issues.
