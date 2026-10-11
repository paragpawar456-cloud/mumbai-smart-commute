# Mumbai Smart Commute

Android commuter app for Mumbai (Flutter). Local trains, metro, buses and, most importantly, the **last mile**: auto stands, shared autos, bus stops and ride-booking links around any station, with every fare and time labelled by source (Scheduled, Estimate, Official, Community, Live).

Free services only: Flutter, Google Sheets + Apps Script backend, Firebase Authentication (Spark plan), OpenStreetMap.

**Download the latest test APK** (no account needed): <https://github.com/paragpawar456-cloud/mumbai-smart-commute/releases/download/latest-build/app-arm64-v8a-release.apk> · older phones: [`app-armeabi-v7a-release.apk`](https://github.com/paragpawar456-cloud/mumbai-smart-commute/releases/download/latest-build/app-armeabi-v7a-release.apk). How to install and what to try: [docs/TESTER_GUIDE.md](docs/TESTER_GUIDE.md).

| Doc | What's in it |
|---|---|
| [docs/STATUS.md](docs/STATUS.md) | Where the build is, what passed, what's next |
| [docs/SETUP.md](docs/SETUP.md) | Firebase, Sheet + Apps Script, Android Studio, building the APK |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Decisions made and why |
| [docs/PHASE1_PLAN.md](docs/PHASE1_PLAN.md) | Research, data sources, costs, risks |
| [docs/SHEET_SCHEMA.md](docs/SHEET_SCHEMA.md) | Every Sheet tab and column (generated) |
| [docs/DATA_ENTRY.md](docs/DATA_ENTRY.md) | Entering timetables, shared autos, fares, buses |
| [docs/TESTER_GUIDE.md](docs/TESTER_GUIDE.md) | Installing the APK and what to test |
| [docs/HARDENING.md](docs/HARDENING.md) · [docs/SECURITY.md](docs/SECURITY.md) | Test results, failure modes, capacity, security checklist |
| [docs/PRIVACY.md](docs/PRIVACY.md) · [docs/TERMS_DRAFT.md](docs/TERMS_DRAFT.md) | Privacy notice and terms (drafts, not legal advice) |

## Quick start

```bash
cp config/dev.example.json config/dev.json     # fill in values, see docs/SETUP.md
flutter pub get
flutter run --dart-define-from-file=config/dev.json
```

The app runs with an empty config too, as a guest app: no sign-in, reports or admin appear until both Firebase and the server are configured (decision D26).

## Tests

```bash
flutter analyze && flutter test          # app
(cd backend && npm test)                 # Apps Script backend, run locally against stubs
```

## Layout

```
lib/
  core/        config, theme, router, network (ApiClient), source labels, providers
  features/    home, routes, map, saved, lastmile, alerts, admin, account, auth, profile, settings
  shared/      app shell (bottom nav), source badge, info/empty states
  l10n/        app_en.arb, app_mr.arb, app_hi.arb
backend/
  apps-script/ Code.gs (router), Auth, Db, Guard, Validate, Handlers, Pack, Reports, Road, Admin, Schema
  tool/        CSV checker, schema doc generator, load-test tool
  test/        Node tests with Apps Script stubs
config/        *.example.json (real dev.json/prod.json are git-ignored)
```

## APK

GitHub Actions builds a release APK on every push to `main` and publishes it as the **Latest test build** release (link at the top). See docs/SETUP.md for local builds and signing.
