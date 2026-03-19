# README Evaluator Guide Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure `README.md` into an evaluator-first Android APK submission guide that a professor can follow without extra project context.

**Architecture:** Replace the current mixed developer README with a submission-oriented document. Keep the primary flow focused on installation, login, evaluation steps, backend requirements, and known limitations, then retain only a short developer appendix.

**Tech Stack:** Markdown, Flutter Android packaging, Supabase configuration

---

### Task 1: Confirm the source-of-truth inputs

**Files:**
- Review: `README.md`
- Review: `docs/submission/android-apk-submission.md`
- Review: `.env.example`
- Review: `android/app/build.gradle.kts`
- Review: `android/app/src/main/AndroidManifest.xml`

**Step 1: Read the existing docs and Android config**

Confirm the README needs to prioritize:
- app name: `DekD Planner`
- Android package: `com.xtxme.dekdplanner`
- APK output path: `build/app/outputs/flutter-apk/app-release.apk`
- required env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `CANVAS_BASE_URL`, `CANVAS_TOKEN`

**Step 2: Identify missing evaluator-facing information**

List the sections that need clearer guidance:
- what the app does
- install steps
- test-account placeholders
- backend accessibility notes
- known limitations

### Task 2: Rewrite README structure

**Files:**
- Modify: `README.md`

**Step 1: Replace the current intro and setup-heavy flow**

Write an evaluator-first structure with these sections:
- title + purpose
- project summary
- repository and APK location
- installation and launch steps
- evaluator account placeholders
- recommended evaluation flow
- backend/environment notes
- known limitations
- short developer notes

**Step 2: Keep placeholders explicit**

Mark any submission-dependent values as things to fill before final submission instead of inventing data.

### Task 3: Review for consistency

**Files:**
- Review: `README.md`
- Review: `docs/submission/android-apk-submission.md`

**Step 1: Check consistency**

Verify the README matches the submission doc for:
- APK path
- install flow
- backend expectations
- release-build caveat about icon tree shaking

**Step 2: Check readability**

Ensure the document is understandable to a non-developer reader and does not bury critical instructions under developer setup notes.

### Task 4: Final verification

**Files:**
- Review: `README.md`

**Step 1: Sanity check formatting**

Read the final Markdown top-to-bottom and confirm:
- section order is logical
- placeholders are obvious
- commands are minimal and correct

**Step 2: Prepare summary**

Report that README is now submission-oriented and note any remaining placeholders that the user must fill manually before handing the APK to the evaluator.
