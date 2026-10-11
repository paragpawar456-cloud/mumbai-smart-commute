# Mumbai Smart Commute: Phase 1 Research and Plan

Status: **awaiting approval** (Phase 2 checkpoint). No code has been written yet.
Research date: 11 Oct 2026. Every claim is tagged **[V]** (verified against the linked source on that date) or **[I]** (inferred or not yet confirmed; needs checking before we depend on it).

---

## A. Feasibility assessment

**Verdict: feasible as a pilot, with three honest limits.**

| Area | Feasible at ₹0? | Note |
|---|---|---|
| Station search, rail network graph, station-to-station routing with interchanges | Yes | Computed on the phone from our own station/route data. No paid API. |
| Suburban and metro timetables | Partly | No official open feed (GTFS) for Mumbai suburban rail, Metro or BEST was found [I]. Timetables must be entered/curated by us, starting with a pilot corridor. This is the biggest ongoing effort, not a cost. |
| Live train running / live bus positions | **No** | No public, permitted API found for Mumbai suburban live status or BEST bus GPS [I]. We show scheduled times labelled "Scheduled", never "Live". |
| Map, walking/road routing | Yes, within limits | OpenStreetMap data + a free routing API, behind our server cache. Free tile servers forbid offline download and give no uptime guarantee [V]. |
| Last-mile finder (stands, stops, pickup points) | Yes | OSM + municipal open data + admin-curated + community reports. Shows *places*, never claims a vehicle is waiting. |
| Ola / Uber / Rapido live prices | **No** | No usable public price API for our case (see F). We open their official app/booking page instead and show a clearly labelled tariff-based estimate for autos/taxis. |
| Auth for 1,000 users | Yes | Firebase Auth Spark plan: 3,000 daily active users, 1,000 verification emails/day, 150 password-reset emails/day [V]. |
| Google Sheets + Apps Script backend | Yes for ~1,000 registered users | 30 simultaneous executions per user, 20,000 URL fetches/day, 6 min/run on consumer accounts [V]. Must be load-tested; heavy reads go to cached JSON, not live Sheet calls. |

**What makes the app worth installing over m-Indicator:** door-to-door journeys that end with a concrete last-mile step ("walk 180 m to the Kalyan West auto stand, approx. ₹45–60 by meter to Yogidham, estimate from MMRTA tariff"), with every number carrying its source and timestamp.

---

## B. m-Indicator features to replicate (chat excluded)

Source: m-Indicator App Store listing and version notes, read 11 Oct 2026 ([apps.apple.com/app/id593278253](https://apps.apple.com/app/id593278253)). "Verified" means the feature is publicly described by the developer; I did not install or test the app.

| Feature | Existing public feature verified? | Implementation status | Data source (ours) | Test status |
|---|---|---|---|---|
| Suburban lines: Central, Western, Harbour, Trans-Harbour, Uran, Virar–Dahanu, Diva–Roha, Neral–Matheran, Pune–Lonavala | Yes [V] | Planned (pilot: Central main line, then Western/Harbour) | Curated Stations/TrainRoutes sheets; OSM geometry | Not started |
| Station search, fastest route between two stations with interchanges | Yes [V] | Planned P4 | On-device graph search | Not started |
| Timetables, AC locals highlighted, train type S/F/L/AC | Yes [V] | Planned P4 | Curated TrainSchedules sheet | Not started |
| Platform numbers, door side | Yes [V] | Later, where verified | Curated; community-corrected | Not started |
| Less-crowded train indication | Yes [V] | Deferred (no data source) | Possible later from community reports | Not started |
| Live train running status / tracking | Yes [V] (theirs) | **Not deliverable** without a permitted feed | None found [I] | n/a |
| Cancellation / megablock alerts, push notifications | Yes [V] | Planned P4/P6 (admin-entered from official railway announcements) | ServiceAlerts sheet + FCM | Not started |
| Station platform maps, rail network map | Yes [V] | Network map planned; platform maps deferred | Our own drawn map (original artwork) | Not started |
| Fares: ticket, monthly and quarterly pass, 1st/2nd class | Yes [V] | Planned P4 | FareRules sheet from published railway fare tables [I: confirm licence] | Not started |
| Metro and monorail; combined rail + metro routing | Yes [V] | Planned P4 (Lines 1, 2A, 7, 3 first) | Curated MetroRoutes; operator published timetables | Not started |
| Buses: BEST, NMMT, TMT, KDMT, MBMT, VVMT, KMT, PMPML; route by number, buses at a stop, buses between two stops | Yes [V] | Planned P5 (BEST + KDMT first for the Kalyan pilot) | BMC open data for BEST stops (KML, public domain) [V]; routes curated [I] | Not started |
| Auto and taxi fare information | Yes [V] | Planned P5 | MMRTA tariff (min. auto ₹27, taxi ₹33 for 1.5 km, from 1 Sep 2026) [V] | Not started |
| Ferry timings | Yes [V] | Deferred | Curated | Not started |
| Emergency telephone numbers | Yes [V] | Planned P4 (official numbers only, with "not an emergency service" notice) | Curated | Not started |
| Save favourite trains / routes | Yes [V] | Planned P4 | Local storage + SavedRoutes sheet | Not started |
| Marathi / Hindi UI | Not confirmed [I] (listing shows English) | Planned P3 (all three languages) | Flutter l10n | Not started |
| Offline schedules | Not confirmed [I] | Planned P4 | On-device cache with "last updated" | Not started |
| Chat, Natak/cinema listings, job listings | Yes [V] | **Excluded** (chat by brief; listings off-mission) | n/a | n/a |

---

## C. Top 10 additional features (ranked by commuter benefit)

1. **Last-mile finder** around any station: stands, stops, pickup points, walking time, source and freshness.
2. **Door-to-door planner**: walk + train/metro + bus/auto in one journey, sorted cheapest / fastest / least walking / fewest changes.
3. **Transparent fare comparison**: each row says *Live quote*, *Tariff estimate*, *Published fare* or *Unknown*, with the calculation shown.
4. **Disruption alerts for saved routes** (from official announcements, admin-entered).
5. **Offline commute pack**: saved routes, timetables and station info usable with no network.
6. **Community reports with expiry**: "auto queue long", "stand moved", "bus stop closed"; auto-stale after a set time, trust score from corroboration.
7. **Departure reminders** for the usual train ("leave in 8 min for the 08:14 Kalyan fast").
8. **Personal dashboard**: home/work shortcuts, recent journeys, one-tap repeat.
9. **Commute cost calculator**: monthly cost of a saved journey vs. a pass.
10. **Accessibility info** (lifts, ramps, step-free), shown only where verified.

---

## D. Technology architecture

```
Flutter app (Android)
 ├─ Riverpod (state) · go_router (navigation) · flutter_map (OSM map)
 ├─ Drift/SQLite offline cache (stations, schedules, saved data, each with source + timestamp)
 ├─ Firebase Auth SDK (email/password, Google sign-in) → gets ID token
 └─ HTTPS → Apps Script Web App (single doPost router)
        ├─ verifies Firebase ID token on every private call
        ├─ role check from Users sheet (admin never trusted from client)
        ├─ CacheService + versioned JSON "data packs" for public data
        ├─ LockService around writes; idempotency key per request
        ├─ proxies routing API (key kept server-side, results cached)
        └─ Google Sheet (private, never shared/published)
Admin dashboard: Apps Script HTML Service web page, same backend, admin role required.
Push: Firebase Cloud Messaging (free) for alerts.
```

Key decisions:
- **Auth:** Firebase Authentication. Apps Script cannot verify RS256 JWT signatures natively, so the backend validates the ID token by calling Firebase's `accounts:lookup` endpoint and caches the result (keyed by token hash) until the token's expiry, to stay well under 20,000 URL fetches/day. Sheets store only UID, display name, email, language, role, status, timestamps. No passwords or tokens.
- **Read path:** Public data (stations, routes, schedules, stops, stands, fares) is published by the backend as versioned JSON packs. The app downloads a pack only when its version changes, so normal use makes almost no Sheet reads. This is what lets Sheets survive 1,000 users.
- **Write path:** profile, saved routes, community reports, admin edits. Throttled per UID, validated, locked, audit-logged.
- **Sheet schema:** the 17 tabs from the brief, with two changes: `TrainSchedules` split into `TrainTrips` + `TripStopTimes` (GTFS-shaped, so a later move to Postgres/GTFS tools is mechanical), and a `RateLimits` tab replaced by CacheService. Full column specs come in Phase 3.
- **Migration path:** when writes or latency exceed the measured limits, move the same API contract to Supabase/Postgres or Firestore; the app only changes its base URL.

---

## E. Free and free-tier data sources

| Data | Source | Access / cost | Limitations |
|---|---|---|---|
| Base map tiles | OSM Foundation `tile.openstreetmap.org` | Free, no key [V] | Best effort, no SLA, can block without notice; **no offline download or prefetch**; identifying User-Agent and visible attribution required [V]. Fine for development and a small pilot; tile URL kept configurable. |
| Map tiles (alternative) | MapTiler free plan | Free, 5,000 sessions [V] | Commercial-use terms not confirmed [I]. |
| Map tiles (alternative) | Stadia Maps free | 200,000 credits/month [V] | **Free tier forbids commercial use**, including ad-supported apps [V]. |
| Stations, stops, auto stands, taxi ranks, footpaths | OpenStreetMap data via Overpass API | Free, ODbL licence | Coverage of auto stands in Kalyan is unknown [I]; we extract once into our sheets, not live per user. Requires "© OpenStreetMap contributors". |
| BEST bus stops and depots | BMC via OpenCity ([dataset](https://data.opencity.in/dataset/mumbai-best-bus-stops-and-depots-data)) | Free, public domain, KML, updated Nov 2025 [V] | Stops only; route sequences and timetables not included [I]. |
| Road/walking routing, geocoding | openrouteservice (HeiGIT) | Free API key | Per-request caps documented (e.g. 50 waypoints) [V]; daily quota and commercial terms not confirmed on their site today [I]. Called only via our backend with caching. |
| Suburban rail timetables | Central/Western Railway published timetables | Free to read | No machine-readable open feed found [I]; redistribution terms unclear [I]. We curate data for the pilot corridor. |
| Live train status (NTES etc.) | — | No permitted public API found [I] | Third-party scrapers exist; brief forbids scraping. Not used. |
| Metro timetables | Operator websites (MMRDA, MMRCL, MMOPL) | Free to read | Not in GTFS form [I]; curated. |
| Auto / taxi tariffs | MMRTA fare revision, effective 1 Sep 2026 | Public [V] | Full per-km table to be copied from the official notification, not news reports. |
| Ride-hailing | Uber universal deep link `m.uber.com/ul/?action=setPickup&pickup[...]&dropoff[...]` [V] | Free developer registration for a client_id | Opens Uber with the trip prefilled; user sees the real price there. |
| Ride-hailing | Ola, Rapido | No public developer API found [I] | Open their app or website only. |
| Integrated ticketing | Mumbai One (MMRDA), launched Oct 2025 [V] | No public API found [I] | Link out only. |

---

## F. How nearby autos, buses and taxi comparisons work (without fake APIs)

What the commuter at Kalyan station heading to Yogidham will see:

1. **Places, not vehicles.** Auto stands, shared-auto points, bus stops and taxi pickup points from OSM + BMC data + admin-curated entries, each labelled *Verified (admin)*, *Map data (OSM)* or *Community reported, 25 min ago*. The UI never says "autos available"; it says "Auto stand".
2. **Walking leg.** Walking route and time from the user's location to each pickup point, via the routing proxy.
3. **Auto and taxi fare = tariff estimate.** Road distance × official MMRTA tariff (minimum fare, per-km, night surcharge when the official notification gives it), shown as a range with the label "Estimate from MMRTA tariff, 1 Sep 2026". Shared-auto fares only where admin-verified or community-reported, labelled as such.
4. **Buses.** Route numbers serving the nearest stops and scheduled times where we have them; "Scheduled", never "Live".
5. **Uber.** A button that opens Uber with pickup and drop prefilled. Fare shown as "Check price in Uber". Uber's Price Estimates endpoint exists [V], but its API terms have historically been used to block price-comparison apps (reported 2016) [I: current terms to be re-read before use], so we do not plan on showing Uber prices side by side.
6. **Ola and Rapido.** "Open Ola" / "Open Rapido" buttons, no prices.
7. **Community reports.** "Long queue at stand", "no autos", "stand shifted": time-stamped, expire after a set period (proposal: 30 min for queues, 7 days for stand changes), rate-limited per user, moderated in admin.
8. **Moving vehicles on the map.** None, because there is no genuine feed. The "alive" feel comes from the user's own position, the animated selected journey line, and fresh community reports. If a real feed appears later, the map layer is already designed to animate timestamped positions.

---

## G. ₹0 pilot cost assessment

| Service | Purpose | Free allowance | Restrictions | Expected pilot cost | Upgrade trigger |
|---|---|---|---|---|---|
| Flutter, Dart, Android Studio, Git | Build | Free | — | ₹0 | — |
| GitHub | Code, CI (Actions) | Free private repos; Actions minutes on free plan [I] | — | ₹0 | CI minutes exceeded |
| Google Sheets + Apps Script | DB + API + admin | 6 min/run, 30 simultaneous runs/user, 20k URL fetch/day, 90 min trigger time/day [V]; 10M cells per spreadsheet [I] | Latency typically 1–3 s per call [I] | ₹0 | Measured p95 latency or quota errors during load test |
| Firebase Auth (Spark) | Login | 3,000 DAU, 1,000 verify emails/day, 150 reset emails/day [V] | Phone/SMS login needs paid Blaze plan [V] | ₹0 | >3,000 DAU or SMS login wanted |
| Firebase Cloud Messaging | Alerts | Free [I] | — | ₹0 | — |
| Firebase Crashlytics | Crash reports | Free [I] | — | ₹0 | — |
| OSM tiles | Map | Free, best effort [V] | No offline; can be blocked | ₹0 | Blocked, or growth beyond pilot |
| openrouteservice | Walking/road routes | Free key [V] | Quota/terms to confirm [I] | ₹0 | Quota hit; self-host OSRM/Valhalla |
| Uber developer account | Deep link client_id | Free [I] | — | ₹0 | — |
| **Google Play Console** | Publishing | **One-time US$25 registration** [I: confirm current fee] | — | **One-time, not recurring** | Only if you publish on Play Store |

**Potential blockers to ₹0:** Play Store fee (one-time), SMS/OTP login (needs paid plan, so we use email + Google sign-in), free tile/routing services withdrawing access, and Apps Script latency under load.

---

## H. Phased plan designed to minimise Claude usage

Each phase ends with a short `STATUS.md` update in the repo (decisions, what passed/failed, next steps) so a new session continues without redoing research.

| Phase | Objective | Main outputs | Done when |
|---|---|---|---|
| 3 Foundation | Project skeleton | Flutter project, theme (light/dark), 5-tab navigation, en/mr/hi l10n scaffold, config for dev/prod, Apps Script router + Sheet schema setup script, Firebase Auth wiring | App builds; `flutter test` passes; backend health endpoint responds |
| 4 Core commuter | Rail/metro | Pilot data (Central main line + Metro), station search, timetables, route planner, map, favourites, offline cache, alerts | Kalyan↔CSMT and Kalyan↔Thane journeys correct against published timetable |
| 5 Last-mile | Differentiator | Pickup-point discovery, walking routes, fare estimate engine, ride-hailing links, community reports with expiry | Kalyan Station → Yogidham dashboard works with labelled sources |
| 6 Accounts and admin | Users + control | Profile, account deletion, consent, admin web dashboard, roles, audit log, data-source health | Admin-only actions rejected for normal users (tested) |
| 7 Hardening | Proof | Unit/widget tests, failure-mode tests, load test with synthetic accounts, security checklist | Documented results, including what failed |
| 8 Delivery | Hand-over | README, setup and deploy guide, release APK build steps, privacy policy and terms drafts | You reproduce the build from the instructions |

Usage-saving rules: one phase per session; small diffs, no regeneration of unchanged files; data entry done via CSV templates you or a helper fill, not by Claude typing timetables; tests run in CI.

---

## I. Major risks and decisions needing your approval

**Risks**
1. **Timetable data effort.** No open feed; curating every line is large. Mitigation: pilot corridor first, CSV import tooling, community corrections.
2. **No live data.** Users may expect "live" like m-Indicator. Mitigation: honest "Scheduled" labels and fast alerts.
3. **Free services can be withdrawn** (OSM tiles, routing). Mitigation: configurable URLs, server-side caching, self-host fallback.
4. **Apps Script latency and quotas** at peak. Mitigation: JSON data packs, caching, measured load test before claiming capacity.
5. **Licensing** of railway timetable/fare data and OSM attribution. Mitigation: attribution screen, source log, legal check before public release.
6. **Ride-hailing terms.** Uber/Ola/Rapido could object to comparison displays. Mitigation: deep links only, no scraped prices.
7. **Privacy (DPDP Act 2023).** Mitigation: minimal data, location only on-device unless the user submits a report, account deletion, consent screens.

**Decisions I'm proposing (approve or change)**
- D1. Pilot geography: **Central main line (CSMT–Kalyan), Kalyan West last-mile, Metro Lines 1/2A/7/3**, then expand.
- D2. Map: **flutter_map + OSM tiles** for the pilot, tile URL configurable; offline map not offered (schedules still offline).
- D3. Auth: **Firebase email/password + Google sign-in**; no phone OTP (it needs a paid plan).
- D4. Ride-hailing: **deep links only**, no displayed Uber/Ola/Rapido prices; autos/taxis via official tariff estimate.
- D5. Admin: **Apps Script web dashboard**, not a separate Android app.
- D6. No ads or paid features during the pilot (keeps us inside free-tier non-commercial terms).

**Questions I need answered**
- Q1. Which GitHub repository should the code go in? (A new empty repo, e.g. `mumbai-smart-commute`, connected to this project is easiest.)
- Q2. Do you plan to publish on the Play Store (one-time ~US$25) or share the APK directly for the pilot?
- Q3. The brief mentions a 3D warehouse reference screenshot, but it wasn't attached. Send it if you want the map styling to draw on it.
