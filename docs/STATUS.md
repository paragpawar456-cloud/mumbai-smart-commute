# Status

Updated: 2026-10-11

## Phase 3: Foundation — done (PR #1, merged)

App shell, en/mr/hi, sign-in code, Apps Script backend, Sheet schema, CI APK. See git history.

## Phase 4: Core commuter functions — in review

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
- "Yogidham" is not tagged in OSM near Kalyan; destination search will need a geocoder or curated places.

## Next

- [ ] Enter the official CR timetable for the pilot corridor (owner or helper, via DATA_ENTRY.md)
- [ ] Phase 5: last-mile finder, fare estimates, ride-hailing links, community reports
