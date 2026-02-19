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

Create `.env` in project root:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
CANVAS_BASE_URL=https://your-canvas-domain
CANVAS_TOKEN=your_canvas_token
```

Notes:

- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are required to run the Flutter app.
- `CANVAS_BASE_URL` and `CANVAS_TOKEN` are used by Edge Function `canvas-proxy`.

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

## 9. Recommended development flow

1. `flutter pub get`
2. Configure `.env`
3. `supabase start` (if using local backend)
4. `flutter run`
5. Work on app in `lib/` and Edge Function in `supabase/functions/canvas-proxy/index.ts`
