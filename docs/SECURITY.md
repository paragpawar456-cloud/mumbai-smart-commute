# Security checklist

Checked 2026-10-11. "Test" names a passing automated test; "Code" points at where it's enforced.

| Check | Result | Evidence |
|---|---|---|
| No passwords, tokens or API keys in the repository | Pass | Repo scan for key/token/private-key patterns found none; `.gitignore` excludes `config/dev.json`, `config/prod.json`, `*.jks`, `android/key.properties` |
| No passwords or tokens stored in the Sheet | Pass | `Users` columns: uid, email, name, language, role, status, consent, dates only (`Schema.gs`); sign-in handled by Firebase |
| Google Sheet never exposed to the app | Pass | App talks only to the Apps Script URL; Sheet stays private to the owner |
| Server verifies who you are | Pass | Firebase ID token checked with `accounts:lookup` (`Auth.gs`); test `private actions reject missing or invalid tokens` |
| Admin rights decided on the server only | Pass | Role read from the `Users` tab (`Auth.requireRole`); tests `client cannot grant itself admin`, `every admin action is rejected for users and moderators` |
| Admin can't remove their own access | Pass | Test `admin changes roles (not their own)` |
| Every admin action logged | Pass | `AdminAuditLog`; tests check entries for role, status, moderation, alerts |
| Spreadsheet formula injection blocked | Pass | `Validate.string` prefixes `= + - @`; tests in `api.test` and `reports.test` |
| Rate limits per user and per action | Pass | `Guard.rateLimit`; test `rate limit kicks in` |
| Retries don't double-write; one user can't replay another's answer | Pass | Tests `duplicate requestId…`, `a requestId reused by another user…` |
| Internal errors not shown to users | Pass | Test `internal errors are not leaked` |
| Community reports don't reveal the reporter | Pass | Public list has no uid; location rounded to ~11 m; test `public list hides uid` |
| Booking links can't be pointed at unsafe sites | Pass | Data pack validation requires `https://` deep links; test `last-mile tables are packed and validated` |
| Alerts must cite an official https source | Pass | Test `alerts: admin creates with an official https source…` |
| Location used only when the user taps it, never sent in the background | Pass | `LocationService` called from "My location" only; road distance sends station and destination points, disclosed in the privacy notice |
| Account deletion removes personal data | Pass | Test `deleteMyData wipes personal fields and blocks further use` |
| Android permissions are the minimum | Pass | Internet and location (fine/coarse) only, in `AndroidManifest.xml` |

## Known limits

- Anonymous read limits are shared by all users (Apps Script can't see IP addresses), so a determined abuser could use up the public read budget for a minute at a time. Data stays correct; the app falls back to its local data.
- Apps Script web apps always answer HTTP 200, so monitoring must read the `ok` field (the app and load-test tool do).
- APKs from CI are debug-signed until signing secrets are added (docs/SETUP.md). Testers must uninstall before installing a build with a different signature.
