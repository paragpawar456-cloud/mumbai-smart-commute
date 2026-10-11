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
| Timetable engine: departures, service days, Sunday-on-holiday, chained connections | Done, tested on test fixtures; **no real timetable loaded yet** |
| Routes screen, Station screen with departures, saved and recent journeys | Done, widget-tested |
| Map: OSM tiles + attribution, station markers, lines, layers, "My location" on tap only | Done; not exercised in automated tests (needs network tiles) |
| Server: getDataPack, validation, Publish menu, sync status, chunked cache | Done, tested with stubs |
| CSV templates + `check_csv.js` | Done |

Tests (2026-10-11): `flutter analyze` clean · `flutter test` 26 passed · `backend npm test` 18 passed.

## Findings that affect Phase 5

- OpenStreetMap has **0 bus stops** and **2 taxi/auto points** tagged within ~2.5 km of Kalyan station (extract of 2026-10-11). Last-mile data for Kalyan must come mainly from admin-verified entries and community reports, not OSM.
- Correction: "Yogidham" **is** in OpenStreetMap (residential area, way/1413460408, plus "Yogidham Phase 3", way/1411150860). An earlier version of this file said it wasn't; that was wrong. Both are now seeded as places.

## Phase 5: Last-mile finder — in review

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

- [ ] Enter the official CR timetable for the pilot corridor (owner or helper, via DATA_ENTRY.md)
- [ ] Check the seeded auto/taxi fares against the official MMRTA tariff card
- [ ] Phase 6: admin dashboard (users, reports moderation, data status)
