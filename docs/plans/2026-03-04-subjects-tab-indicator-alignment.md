# Subjects Tab Indicator Alignment Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align the subjects page tab indicator directly under the selected tab label center and make the active tab text plus indicator use the same color as the Import button background.

**Architecture:** Keep the existing `SubjectsTabSwitch` structure, but compute label width with `TextPainter` so the indicator position is derived from the text width and the selected tab's center point, not from the expanded widget bounds. Use `AppColors.accent` for both the active tab text and the underline so the selected state matches the Import button styling.

**Tech Stack:** Flutter, Material, existing `AppColors` theme tokens

---

### Task 1: Fix indicator positioning and color

**Files:**
- Modify: `lib/features/subjects/subjects_page/widgets/subjects_tab_switch.dart`

**Step 1: Update tab measurement targets**

Replace the widget-key measurement approach with deterministic text-width calculation using the selected label style.

**Step 2: Recompute indicator offset from label bounds**

Compute each tab width from the available layout width and place the underline by centering the measured label width inside the selected tab.

**Step 3: Keep indicator color consistent**

Use `AppColors.accent` for the active tab label and the underline so both match the Import button background color.

**Step 4: Validate the file**

Run: `flutter analyze lib/features/subjects/subjects_page/widgets/subjects_tab_switch.dart`
Expected: PASS with no issues in the modified file.
