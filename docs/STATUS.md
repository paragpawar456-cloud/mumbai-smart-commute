# Status

Updated: 2026-10-11

## Phase 3: Foundation — done (PR #1, merged)

App shell, en/mr/hi, sign-in code, Apps Script backend, Sheet schema, CI APK. See git history.

## Phase 4: Core commuter functions — done (PR #2, merged)

| Item | Result |
|---|---|
| Pilot stations: Central main line CSMT–Kalyan (26) + Metro Line 1 (12), coordinates and Marathi/Hindi names from OpenStreetMap | Done |
| Data pack: bundled in app → cached on phone → refreshed from server when version is newer | Done, tested |
| Station search (English, Marathi, Hindi, station code) | Done, tested |
| Route planner with changes and walking interchange (Ghatkopar) | Done, tested |
| Timetable engine: departures, service days, Sunday-on-holiday, chained connections | Done; 872 Central Railway Main Line trains loaded from the official timetable (D30) |
| Routes screen, Station screen with departures, saved and recent journeys | Done, widget-tested |
| Map: OSM tiles + attribution, station markers, lines, layers, "My location" on tap only | Done; not exercised in automated tests (needs network tiles) |
| Server: getDataPack, validation, Publish menu, sync status, chunked cache | Done, tested with stubs |
| CSV templates + `check_csv.js` | Done |

Tests (2026-10-11): `flutter analyze` clean · `flutter test` 26 passed · `backend npm test` 18 passed.

## Findings that affect Phase 5

- OpenStreetMap has **0 bus stops** and **2 taxi/auto points** tagged within ~2.5 km of Kalyan station (extract of 2026-10-11). Last-mile data for Kalyan must come mainly from admin-verified entries and community reports, not OSM.
- Correction: "Yogidham" **is** in OpenStreetMap (residential area, way/1413460408, plus "Yogidham Phase 3", way/1411150860). An earlier version of this file said it wasn't; that was wrong. Both are now seeded as places.

## Phase 5: Last-mile finder — done (PR #3, merged)

| Item | Result |
|---|---|
| "Station to doorstep" screen: pick station, search a place or drop a pin on the map | Done, widget-tested (Kalyan → Yogidham) |
| Options: walk, auto and taxi by meter, shared autos, buses, Uber/Ola/Rapido links; sort by cheapest, fastest, least walking | Done, tested |
| Fare estimates from the FareRules tab, night charge, rule effective dates; "from ₹X" when only the minimum fare is known | Done, tested |
| Seeded fares: auto ₹27 for 1.5 km then ₹18.22/km, taxi ₹33 then ₹21.90/km, +25% 00:00–05:00, from 1 Sep 2026 | **As reported by Time Out Mumbai and Mid-Day**; replace with the official MMRTA tariff card when available |
| Places (7 around Kalyan incl. Yogidham) and 2 auto stands from OpenStreetMap | Done; no shared-auto routes or bus routes entered yet |
| Ride-hailing: Uber opens with the trip filled in; Ola and Rapido open their Play Store page. No prices shown | Done |
| Community reports: submit, list nearby, "still true", moderator approve/reject, expiry per type, audit log | Done, server tested; screen not tested against a live server |
| Road distance via openrouteservice (optional free key), cached; falls back to straight line × 1.3, labelled | Done, tested with stubs |
| Places, stands, bus data, fares and providers validated on Publish and in `check_csv.js` | Done, tested |

Tests (2026-10-11): `flutter analyze` clean · `flutter test` 35 passed · `backend npm test` 26 passed.

### What the Kalyan → Yogidham screen can't show yet

- Shared autos and their per-seat fares: nobody has entered them. Add them in the `PickupPoints` tab (kind `shared_auto`, `destinations`, `shared_fare_inr` with `fare_source`).
- KDMT buses: OSM has no bus stops here and there is no open KDMT feed. Enter stops and routes by hand in `BusStops`/`BusRoutes` if wanted.

## Next

- [x] Load the official CR Main Line timetable (from CR's pocket timetable PDFs, D30)
- [ ] Replace it when CR publishes a newer Main Line timetable (rerun `tool/pack/import_cr_timetable.py`)
- [ ] Check the seeded auto/taxi fares against the official MMRTA tariff card
- [ ] Owner: set up Firebase and the Sheet (docs/SETUP.md); sign-in, reports, alerts and admin then appear by themselves
- [ ] Owner: run `backend/tool/loadtest.js` after deploying and record the numbers in HARDENING.md
- [ ] Owner (optional): add signing secrets so testers can update without uninstalling

## Phase 6: Accounts and admin — done (PR #4, merged)

| Item | Result |
|---|---|
| Admin section in the app (Profile → Admin), shown only when the server says you are admin or moderator | Done, widget-tested with a fake server |
| Overview: users by status and role, reports waiting, alerts in force, data pack version and publish time, data source health, road distance on/off | Done, tested |
| Reports moderation (approve/reject) for moderators and admins | Done, tested |
| Users: search, disable/enable, change role (never your own) | Done, tested |
| Service alerts: admins publish official announcements with an https source link; shown on Home and on affected stations, labelled Official | Done, tested |
| Audit log viewer, newest first | Done, tested |
| Privacy notice (en/mr/hi), consent recorded on the server per notice version | Done, tested |
| Every admin action rejected for normal users and moderators on the server, and for signed-out calls | Done, tested for all 8 admin actions |
| Fixed: two cache keys (report lists, alerts) could repeat within the same millisecond and serve a stale list for up to a minute | Fixed, tested |

Tests (2026-10-11): `flutter analyze` clean · `flutter test` 42 passed · `backend npm test` 31 passed.

## Guest-only build — done (PR #5)

Sign-in, account, server status and commuter-report UI are hidden until both Firebase and the server are configured (D26).

## Phase 7: Hardening — done (PR #6, merged)

Failure-mode tests for the data pack and network; three bugs found and fixed (broken server pack, storage-full caching, Marathi/Hindi garbled when the server sends no charset). Load-test tool written and checked locally; capacity is calculated, not yet measured. Security checklist passed. Details: [HARDENING.md](HARDENING.md), [SECURITY.md](SECURITY.md).

## Phase 8: Delivery — done (PR #6, merged)

Direct APK download link, README, [TESTER_GUIDE.md](TESTER_GUIDE.md), [PRIVACY.md](PRIVACY.md) and [TERMS_DRAFT.md](TERMS_DRAFT.md) (drafts, need review before a public launch).

## Door-to-door search fix — done (PR #7, merged)

Tester report: typing "yogidham" to "runwal" on Home found nothing, because Home only understood station names. Home's From and To now open one search across stations, the app's own places and OpenStreetMap (free Photon server, only the typed words are sent; D27), plus "My location" and "Pick on the map". Any two points get a trip page: the train with road legs at each end (nearest station), and direct road options with estimated fares. Station to station still opens the train planner.

The tester's "map arrives in the next update" screen came from an old install; the map has been live since Phase 4. Builds without signing secrets used a new debug key each time, so a new APK wouldn't install over an old one. CI now keeps one debug key between builds (D28); this one more time, the old app has to be uninstalled first.

## Journey options and "Where is my" — in review

Tester feedback: the trip page looked basic; wanted 3 to 4 options, a train timetable, and animated "Where is my train / auto / bus".

- Trip page lists every way to go (train + auto, auto all the way, taxi or cab, bus, walk) with estimated time, fare, and Fastest / Cheapest tags.
- Train option: each step, a switch for nearby stations (e.g. Thane instead of Kalwa), and the trains between the two stations from the timetable.
- "Where is my train": the train moving down its line by the timetable, with a countdown to your station. Labelled Scheduled, not live (D29).
- "Where is my auto / bus": stands or stops on a map with pulsing markers, and cab-app buttons. No live positions exist, so no fake vehicles (D29). Also on Home and from station departures.
- Train times: 872 Main Line trains from Central Railway's official timetable dated 5 Oct 2024 (302 run Kalyan to Thane). Each list says so and asks riders to check the station display, since some trains changed later (D30).

Tests (2026-10-11): `flutter analyze` clean · `flutter test` 70 passed · `backend npm test` 31 passed.
