# Android APK Submission

## Repository

- GitHub: `https://github.com/xtxme/DekD-Planner-UI.git`

## APK Artifact

- Output path: `build/app/outputs/flutter-apk/app-release.apk`

Build command:

```bash
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

## Installation Steps

1. Transfer `app-release.apk` to the Android device.
2. Open the APK file on the device.
3. Allow installation from local files if Android prompts for permission.
4. Install and open `DekD Planner`.

## Backend For Evaluation

- Mobile app backend: fill in the deployed Supabase project used for evaluation
- Required runtime variables:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `CANVAS_BASE_URL`
  - `CANVAS_TOKEN`
- Requirement: the backend must be reachable from a physical mobile device. Do not use localhost-only services for the final APK.

## Test Account

- Email: fill in evaluator account email
- Password: fill in evaluator account password
- Notes: add any required role, seed data, or onboarding details

## Known Limitations

- Current release APK is built for coursework sideload testing and may still use debug signing.
- Release builds require `--no-tree-shake-icons` because the app reconstructs some Material icons from stored codepoints.
- If notifications are part of the evaluation, Android permission prompts must be accepted during testing.

## Final Submission Checklist

- [ ] `build/app/outputs/flutter-apk/app-release.apk`
- [ ] `README.md` updated
- [ ] `.env.example` updated
- [ ] backend details filled in
- [ ] test account filled in
- [ ] repository link included

## Evaluator Flow

1. Install APK on an Android device.
2. Open `DekD Planner`.
3. Sign in with the provided credentials.
4. Verify that core features load data from the configured backend.
