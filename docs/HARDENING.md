# Hardening results (Phase 7)

Date: 2026-10-11. What was tested, what failed, what was fixed, and what still needs a real deployment to measure.

## Automated tests

| Suite | Count | Covers |
|---|---|---|
| `flutter test` | 49 | Route planner, timetable rules, station and place search, last-mile engine and fares, data pack loading and failure modes, API client errors, every screen's main path, admin role gating, consent, guest mode with no sign-in |
| `backend npm test` | 31 | Every API action against Apps Script stubs: auth, rate limits, replay, formula injection, data pack validation, community reports, road distance, admin roles, alerts |

Both run on every pull request and every push to `main` (GitHub Actions, free).

## Failure modes checked

| What goes wrong | What the app does | Test |
|---|---|---|
| No internet / server times out | Keeps the bundled or cached data, keeps working | `data_pack_repository_test: server timeout…` |
| Server returns an HTML error page | Rejected as a bad response, nothing shown from it | `server HTML error page is rejected` |
| Server sends a broken data pack | Ignored; the working pack stays | `malformed pack… never replaces a working one` (**was a bug, fixed**) |
| Phone storage full when caching a new pack | Uses the new pack for this session anyway | `a newer pack is still used when it cannot be cached` (**was a bug, fixed**) |
| Cached pack file corrupted | Falls back to the pack built into the app | `corrupt cache file falls back…` |
| Server reply without a charset header | Marathi and Hindi text decoded correctly | `newer pack is used and cached…` (**was a bug: text would have been garbled; fixed**) |
| No timetable entered | Plans routes, shows no times, says why | `route_planner_test`, `app_shell_test` |
| No fare rates entered | Says fares can't be estimated, still lists walking, buses, apps | `lastmile_engine_test` |
| Accounts not set up | No sign-in anywhere; everything else works | `profile works in guest mode…` |
| Same request sent twice (retry) | Server replays the first answer, writes once | `api.test: duplicate requestId…` |
| Two alerts saved in the same millisecond | Distinct IDs (**was a bug, fixed in Phase 6**) | `admin.test: alerts…` |

## Capacity: calculation, not yet measured

Google's free limits for Apps Script on a personal account (checked 11 Oct 2026, see PHASE1_PLAN): 30 simultaneous executions, 6 min per run, 20,000 URL fetches a day.

For 1,000 users opening the app about twice a day:

| Call | Per day | Notes |
|---|---|---|
| `getDataPack` (normally "unchanged") | ~2,000 | Answered from config, no Sheet scan |
| `getAlerts` | ~2,000 | Cached 60 s for everyone |
| `listReports` (last-mile screen) | ~1,000 | Cached 60 s per area |
| URL fetches (token checks, road distance) | well under 20,000 | Token checks cached 10 min; road distance cached 6 h |

Busiest 15 minutes (say 20% of users at 8–9 am): about 0.5 calls per second, which needs roughly 1–2 of the 30 simultaneous executions if each call takes 1–3 s.

**This is arithmetic, not a measurement.** After deploying (docs/SETUP.md), run:

```bash
node backend/tool/loadtest.js https://script.google.com/macros/s/…/exec --users 30 --seconds 120
```

It sends only read calls and prints p50/p95 latency and any error codes per action. Record the result here before telling anyone how many users the pilot supports. The tool was checked against a local fake server only; it has not been run against Google yet because the server isn't deployed.

## Security

See [SECURITY.md](SECURITY.md).
