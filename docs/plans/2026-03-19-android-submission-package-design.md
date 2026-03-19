# Android Submission Package Design

**Date:** 2026-03-19  
**Goal:** Prepare the Flutter app for course submission as an installable Android APK that works on a real mobile device against a reachable backend.

## Problem Statement

The current project can run in development, but it is not yet packaged cleanly for handoff:

1. Android identity still uses placeholder values such as `com.example.my_first_app`.
2. Release packaging is not documented as a submission flow.
3. The app requires runtime environment variables and a live backend, which must be explicit in submission instructions.
4. The deliverable needs to include both the APK and enough documentation for the evaluator to install and test it successfully.

## Approaches Considered

### 1. Reuse the current backend and harden Android packaging

Use the existing Supabase/backend setup, update Android app metadata, document the required environment and evaluator flow, and build a release APK.

**Pros**
- Fastest path to a working submission
- Lowest implementation risk
- Keeps the deployed backend aligned with the app already under development

**Cons**
- Depends on the current backend already being stable and publicly reachable

### 2. Create a separate submission backend

Provision a dedicated backend for the submission build, then point the mobile app to that environment.

**Pros**
- Cleaner separation between development and submission data
- Reduced risk from future development changes

**Cons**
- More setup and validation work
- More moving pieces to document and maintain

### 3. Submit source and instructions only

Provide repository and setup instructions without a ready-to-install APK.

**Pros**
- Minimal packaging work

**Cons**
- Does not satisfy the requirement that evaluators can directly install and try the app

## Chosen Approach

Use **Approach 1**: keep the current backend, make Android packaging submission-ready, and provide explicit installation/testing documentation.

This meets the assignment requirement with the least risk and avoids backend migration work unless the current environment proves inaccessible from a real device.

## Design

### Android Packaging

- Replace placeholder Android package identity with a submission-ready identifier.
- Update app label so the installed app appears with the expected product name.
- Keep APK delivery as the primary artifact.
- Preserve current release signing behavior unless a dedicated keystore is available; for classroom sideloading this is acceptable, but the documentation must state the limitation.

### Runtime Configuration

- Keep `.env`-based initialization because the app already depends on it at startup.
- Ensure `.env.example` documents only non-secret placeholders.
- Confirm the submission build uses a real backend configuration that works on a physical phone.
- Explicitly call out that localhost-only services are not valid for the final APK.

### Submission Artifacts

The deliverable set will contain:

- `build/app/outputs/flutter-apk/app-release.apk`
- Updated `README.md` with build and test instructions
- A focused submission note with install/test/backend details
- The repository link: `https://github.com/xtxme/DekD-Planner-UI.git`

### Validation

Before considering the package ready:

1. Run dependency install and static checks.
2. Build the release APK successfully.
3. Verify the APK artifact exists.
4. Confirm backend variables are present for the release build.
5. Document evaluator steps clearly, including any login or test-account requirements.

## Files Expected To Change

- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/.../MainActivity.kt`
- `README.md`
- `.env.example`
- `docs/plans/2026-03-19-android-submission-package.md`

## Risks

- If the backend environment is incomplete or not publicly reachable, the APK can install but fail at runtime.
- If notification or deep-link flows require additional device permissions, the evaluator needs that documented.
- If a real signing key is required by course policy, the current debug-signed release flow must be replaced.

## Success Criteria

- The app builds as a release APK without errors.
- The installed Android app shows the intended app name and package identity.
- The app can connect to a reachable backend on a real device.
- The submission package includes enough documentation for an evaluator to install and test it without local setup guesswork.
