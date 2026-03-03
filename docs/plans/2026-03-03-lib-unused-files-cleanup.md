# Lib Unused Files Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove `lib/` files that are no longer referenced anywhere in the app.

**Architecture:** Build a local dependency map for Dart files under `lib/`, confirm each zero-inbound file is not imported elsewhere in the repository, then delete only the orphaned wrappers, placeholders, and superseded files. Finish with static verification so the cleanup does not regress compilation.

**Tech Stack:** Flutter, Dart, Riverpod, ripgrep

---

### Task 1: Identify orphaned files

**Files:**
- Read: `pubspec.yaml`
- Read: `lib/**/*.dart`

**Step 1: Build dependency map**

Run a local script that resolves package and relative Dart imports to find files with zero inbound references.

**Step 2: Cross-check repository references**

Run: `rg -n --fixed-strings "<candidate-file-path>" .`
Expected: no code references outside the file itself.

### Task 2: Remove unused files

**Files:**
- Delete: `lib/features/assignments/add_assignments/widgets/add_assignment_save_button.dart`
- Delete: `lib/features/assignments/widgets/add_assignment_deadline_card.dart`
- Delete: `lib/features/assignments/widgets/add_assignment_input_shell.dart`
- Delete: `lib/features/auth/providers.dart`
- Delete: `lib/features/home/providers.dart`
- Delete: `lib/features/settings/providers.dart`
- Delete: `lib/features/subjects/edit_subjects.dart`
- Delete: `lib/features/subjects/subjects_page/widgets/grid.dart`
- Delete: `lib/models/assignment.dart`
- Delete: `lib/models/subject.dart`
- Delete: `lib/models/user.dart`
- Delete: `lib/services/auth/password_utils.dart`
- Delete: `lib/services/database/auth_user_dao.dart`
- Delete: `lib/shared/widgets/common_button.dart`
- Delete: `lib/shared/widgets/custom_textfield.dart`
- Delete: `lib/shared/widgets/loading_indicator.dart`

**Step 1: Delete only confirmed orphan files**

Remove the files above without changing referenced code paths.

### Task 3: Verify cleanup

**Files:**
- Read: `lib/**/*.dart`

**Step 1: Run static verification**

Run: `flutter analyze`
Expected: no new missing-import or missing-symbol errors caused by the deletions.
