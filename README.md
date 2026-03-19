# DekD Planner UI

Flutter app for DekD Planner with Supabase backend and a Supabase Edge Function (`canvas-proxy`).

## 1. Prerequisites

Install these tools first:

- Flutter SDK (recommended: latest stable)
- Dart SDK (comes with Flutter)
- Xcode (for iOS/macOS) or Android Studio + Android SDK (for Android)
- Supabase CLI (`brew install supabase/tap/supabase` on macOS)
- Deno VS Code extension (recommended for `supabase/functions/*`)

Check versions:

```bash
flutter --version
flutter doctor
supabase --version
```

## 2. Clone project

```bash
git clone <your-repo-url>
cd DekD-Planner-UI
```

## 3. Install dependencies

```bash
flutter pub get
```

## 4. Configure environment variables

This project reads `.env` at app startup (`lib/core/supabase/supabase_initializer.dart`).

Start from the safe template that can be committed to GitHub:

```bash
cp .env.example .env
```

Then fill in the real values in `.env`:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
CANVAS_BASE_URL=https://your-canvas-domain
CANVAS_TOKEN=your_canvas_token
```

Notes:

- `.env.example` is safe to commit. Keep real secrets only in `.env`.
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are required to run the Flutter app.
- `CANVAS_BASE_URL` and `CANVAS_TOKEN` are used by Edge Function `canvas-proxy`.
- `.env` is bundled as a Flutter asset for the app build, so the final APK must be built with real values that point to a backend reachable from a physical mobile device.

## 5. Run Flutter app

Start emulator/simulator or connect a device, then run:

```bash
flutter run
```

Useful options:

```bash
flutter run -d chrome     # web
flutter run -d ios        # iOS simulator/device
flutter run -d android    # Android emulator/device
```

Quick cleanup (for disk-full/temp cache issues):

```bash
./tool/cleanup.sh && flutter run
```

## 6. (Optional) Run Supabase locally

If you want local backend + Edge Function testing:

```bash
supabase start
supabase db reset
```

Then serve functions locally:

```bash
supabase functions serve canvas-proxy --env-file .env
```

Example invoke URL:

```text
http://127.0.0.1:54321/functions/v1/canvas-proxy
```

## 7. Database migrations

Migrations are in `supabase/migrations`:

- `001_init.sql`
- `002_feature_complete_schema.sql`

Apply them with:

```bash
supabase db reset
```

## 8. Common issues

- `Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env`
  - Verify `.env` exists in project root and keys are correct.

- TypeScript error in Edge Function: `Cannot find name 'Deno'`
  - Open project in VS Code with Deno extension enabled.
  - Ensure `.vscode/settings.json` keeps `"deno.enablePaths": ["supabase/functions"]`.

- Flutter build/run fails
  - Run `flutter doctor` and fix missing platform dependencies.

## 9. Android APK build

Build the submission APK with:

```bash
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

Artifact:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Notes:

- The release APK is intended for Android sideload testing.
- Make sure `.env` contains the real `SUPABASE_URL` and `SUPABASE_ANON_KEY` before building.
- If your backend only runs on `localhost` or `127.0.0.1`, the APK will install but will not work on a real phone.
- This project stores some Material icon codepoints dynamically, so release builds must use `--no-tree-shake-icons`.

## 10. Submission checklist

- `build/app/outputs/flutter-apk/app-release.apk`
- updated `README.md`
- `.env.example`
- backend details for evaluation
- test account for evaluator, if authentication is required
- repository link: `https://github.com/xtxme/DekD-Planner-UI.git`

## 11. Recommended development flow

1. `flutter pub get`
2. Configure `.env`
3. `supabase start` (if using local backend)
4. `flutter run`
5. Work on app in `lib/` and Edge Function in `supabase/functions/canvas-proxy/index.ts`
