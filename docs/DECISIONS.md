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
| D13 | OpenStreetMap extract runs in GitHub Actions (`osm-extract.yml`) and is committed to `data/osm` | Reproducible, free, and works where the build machine can't reach Overpass | 2026-10-11 |
| D14 | App ships stations and lines but **no timetable**; times only after an official timetable is entered and published | No open timetable feed exists; never invent times | 2026-10-11 |
| D15 | Route planner runs on the phone (stops + change penalty); scheduled times added only when trips exist | Works offline; no routing API cost | 2026-10-11 |
| D16 | Anonymous rate limits are global per action (600/min), not per device | Apps Script can't see client IPs; per-user limits apply once signed in | 2026-10-11 |
| D17 | Map lines drawn straight between stations, labelled as such | Exact track geometry not needed for the pilot; never implies more precision than we have | 2026-10-11 |
| D18 | Last-mile engine runs on the phone from the data pack; straight line × 1.3 for road distance unless openrouteservice returns one | Works offline and at ₹0; every estimate shows its assumptions | 2026-10-11 |
| D19 | Seeded auto/taxi fares labelled "as reported" by two news outlets until the official MMRTA card is entered; all meter fares shown as Estimate | Official card wasn't reachable; never present an estimate as exact | 2026-10-11 |
| D20 | Uber via its universal link (trip prefilled); Ola and Rapido open their Play Store page | No documented public deep link for Ola/Rapido; no prices from any provider | 2026-10-11 |
| D21 | Community reports: signed-in only, 5 live per user, location rounded to ~11 m, uid never public, one "still true" per user (hashed), expiry per type | Useful, abuse-resistant, and keeps reporters private | 2026-10-11 |
| D22 | A pickup point is a place where vehicles are usually found; the app always says it can't see vehicles there now | No live vehicle data exists; avoids implied availability | 2026-10-11 |
| D23 | Admin dashboard lives inside the app (Profile → Admin), not an Apps Script web page; replaces D5 | Reuses the app's sign-in and role checks; Firebase sign-in inside Apps Script's sandboxed page is unreliable; one codebase. The Sheet stays the owner's bulk-editing tool | 2026-10-11 |
| D24 | Service alerts must link to the official announcement (https) and are shown as Official | Never publish disruptions without a checkable source | 2026-10-11 |
| D25 | Privacy consent is recorded per notice version; the app asks again when the notice changes. Not enforced on the server | Honest record without locking people out of public data | 2026-10-11 |
