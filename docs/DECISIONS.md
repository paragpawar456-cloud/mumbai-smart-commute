# Decisions

| # | Decision | Why | Date |
|---|---|---|---|
| D1 | Pilot: Central main line (CSMT–Kalyan), Kalyan West last mile, Metro Lines 1/2A/7/3 | Matches the Kalyan → Yogidham acceptance scenario; timetables must be curated by hand | 2026-10-11 |
| D2 | flutter_map + OSM tiles, tile URL configurable; no offline map tiles | Free; OSMF policy forbids offline/bulk download | 2026-10-11 |
| D3 | Firebase Auth email/password + Google sign-in; no phone OTP | Spark plan is free; SMS needs the paid Blaze plan | 2026-10-11 |
| D4 | Ride-hailing via deep links only, no displayed Uber/Ola/Rapido prices; autos/taxis by MMRTA tariff estimate | No usable public price APIs; never fabricate prices | 2026-10-11 |
| D5 | Admin dashboard as a web page on the same Apps Script backend (Phase 6) | Cheaper than a second Android app | 2026-10-11 |
| D6 | No ads or paid features in the pilot | Keeps free-tier terms (several forbid commercial use) | 2026-10-11 |
| D7 | Free only: APK shared directly, no Play Store (US$25 fee) | Owner asked for free things only | 2026-10-11 |
| D8 | New repo `mumbai-smart-commute` instead of reusing `transitmatrix` | transitmatrix is Kotlin on paid Google Maps APIs | 2026-10-11 |
| D9 | Apps Script verifies Firebase ID tokens via `accounts:lookup`, cached 10 min by token hash | Apps Script can't verify RS256 locally; cache keeps UrlFetch far under 20k/day | 2026-10-11 |
| D10 | Single POST endpoint `{action, payload, idToken, requestId}` with structured `{ok, data|error}` | Apps Script web apps only expose doGet/doPost and always return HTTP 200 | 2026-10-11 |
| D11 | Schema changes vs brief: `TrainSchedules` → `TrainTrips` + `TripStopTimes` (GTFS-shaped); `MetroRoutes` merged into `TrainRoutes` (mode column); `AutoStands` → `PickupPoints` (auto/shared/taxi/ride pickup) | Easier later migration to GTFS/Postgres; one place for all last-mile pickup points | 2026-10-11 |
| D12 | Riverpod 3 + go_router; Firebase options passed via `--dart-define-from-file`, not google-services.json | No Gradle plugin needed; app still builds and runs without Firebase | 2026-10-11 |
