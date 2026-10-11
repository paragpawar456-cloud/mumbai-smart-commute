# Mumbai Smart Commute

Android commuter app for Mumbai (Flutter). Local trains, metro, buses and, most importantly, the **last mile**: auto stands, shared autos, bus stops and ride-booking links around any station, with every fare and time labelled by source (Scheduled, Estimate, Official, Community, Live).

Free services only: Flutter, Google Sheets + Apps Script backend, Firebase Authentication (Spark plan), OpenStreetMap.

| Doc | What's in it |
|---|---|
| [docs/STATUS.md](docs/STATUS.md) | Where the build is, what passed, what's next |
| [docs/SETUP.md](docs/SETUP.md) | Firebase, Sheet + Apps Script, Android Studio, building the APK |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Decisions made and why |
| [docs/PHASE1_PLAN.md](docs/PHASE1_PLAN.md) | Research, data sources, costs, risks |
| [docs/SHEET_SCHEMA.md](docs/SHEET_SCHEMA.md) | Every Sheet tab and column (generated) |

## Quick start

```bash
cp config/dev.example.json config/dev.json     # fill in values, see docs/SETUP.md
flutter pub get
flutter run --dart-define-from-file=config/dev.json
```

The app runs with an empty config too: sign-in shows "not configured" and the server status says so, but nothing crashes.

## Tests

```bash
flutter analyze && flutter test          # app
(cd backend && npm test)                 # Apps Script backend, run locally against stubs
```

## Layout

```
lib/
  core/        config, theme, router, network (ApiClient), source labels, providers
  features/    auth, home, routes, map, saved, profile, settings
  shared/      app shell (bottom nav), source badge, info/empty states
  l10n/        app_en.arb, app_mr.arb, app_hi.arb
backend/
  apps-script/ Code.gs (router), Auth.gs, Db.gs, Guard.gs, Validate.gs, Handlers.gs, Schema.gs
  test/        Node tests with Apps Script stubs
config/        *.example.json (real dev.json/prod.json are git-ignored)
```

## APK

GitHub Actions builds a release APK on every push to `main`: open the latest **CI** run, then download **mumbai-smart-commute-apk** under Artifacts. See docs/SETUP.md for local builds and signing.
