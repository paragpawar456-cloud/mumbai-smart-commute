# Status

Updated: 2026-10-11

## Phase 3: Foundation — done

| Item | Result |
|---|---|
| Flutter project (Android), Material 3 theme, light/dark, large touch targets | Done |
| 5-tab navigation: Home, Routes, Live Map, Saved, Profile | Done |
| English, Marathi, Hindi (selectable, saved) | Done. Marathi/Hindi need a native-speaker review |
| Dev/prod config via `--dart-define-from-file` | Done |
| Firebase Auth: register, verify email, sign in, Google, reset, sign out, delete | Code done; **not tested against a real Firebase project yet** (needs your Firebase setup) |
| Guest mode when Firebase/backend not configured | Done, tested |
| ApiClient with structured errors, request IDs, timeouts | Done, tested |
| Apps Script backend: router, token check, roles from Sheet, rate limit, duplicate-request replay, validation, formula-injection guard, audit log | Done, tested locally with stubs; **not yet deployed** |
| Sheet schema (17 tabs) + `setupSheets()` | Done; doc generated in SHEET_SCHEMA.md |
| CI: analyze, tests, release APK artifact | Workflow added; first run happens on push |

Tests (run 2026-10-11): `flutter analyze` no issues · `flutter test` 12 passed · `backend npm test` 14 passed.

Not verified here: an actual APK build (the build container can't download the Android SDK; GitHub Actions builds it), and a live Apps Script deployment.

## Next: Phase 4, core commuter functions

- [ ] Pilot data CSV templates + import (Stations, TrainRoutes, TrainTrips, TripStopTimes, FareRules)
- [ ] Data pack endpoint (versioned JSON) + on-device cache with source/timestamp
- [ ] Station search, timetable view (Scheduled labels)
- [ ] Station-to-station routing with interchanges (on device)
- [ ] Map: flutter_map, OSM attribution, user and destination markers, layers
- [ ] Favourites and recent searches
- [ ] Service alerts (admin-entered) display

## Waiting on owner

- Firebase project + Apps Script deployment (steps in SETUP.md) to test sign-in end to end.
