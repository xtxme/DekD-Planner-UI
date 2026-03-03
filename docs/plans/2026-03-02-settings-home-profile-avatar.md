# Settings and Home Profile Avatar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Show the user's profile-backed display name and avatar on the Settings and Home screens.

**Architecture:** Reuse `profileProvider` as the source of truth for profile presentation data while keeping `authSessionProvider` for auth-backed email and fallback naming. Update the shared Settings account card to accept an avatar URL and render a network image when available.

**Tech Stack:** Flutter, Riverpod, Supabase

---

### Task 1: Settings Profile Data

**Files:**
- Modify: `lib/features/settings/settings_page.dart`
- Modify: `lib/features/settings/widgets/account_section_card.dart`

**Step 1: Read `profileProvider` in `SettingsPage`**

Watch the profile provider and derive `displayName`/`avatarUrl` with auth fallbacks.

**Step 2: Pass avatar data into the account card**

Extend the `SettingsAccountCard` callsite with the new avatar prop.

**Step 3: Render network avatar in the card**

Update the card widget to show a profile photo when `avatarUrl` is present, otherwise keep the existing placeholder icon.

### Task 2: Home Header Profile Data

**Files:**
- Modify: `lib/features/home/home_page.dart`

**Step 1: Read `profileProvider` in `HomePage`**

Derive greeting name from profile first, then auth session as fallback.

**Step 2: Render the avatar in the header**

Replace the hardcoded placeholder avatar with a network image when a profile avatar URL exists.

### Task 3: Verification

**Files:**
- Modify: `lib/features/settings/settings_page.dart`
- Modify: `lib/features/settings/widgets/account_section_card.dart`
- Modify: `lib/features/home/home_page.dart`

**Step 1: Format changed files**

Run `dart format` on the three updated files.

**Step 2: Run focused analysis**

Run `flutter analyze` for the updated files and verify there are no issues.
