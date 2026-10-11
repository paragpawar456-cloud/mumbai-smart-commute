# Tester guide

## Install

1. On the Android phone, open <https://github.com/paragpawar456-cloud/mumbai-smart-commute/releases/download/latest-build/app-arm64-v8a-release.apk>. Very old phones (32-bit): use `app-armeabi-v7a-release.apk` from the same [release page](https://github.com/paragpawar456-cloud/mumbai-smart-commute/releases/tag/latest-build).
2. Open the downloaded file. Android will ask to allow installs from your browser: allow it once.
3. Updating: if Android says the app "conflicts with an existing package", uninstall the old version first. That happens until the builds are signed with a fixed key.

## What to try

| Try | What you should see |
|---|---|
| Home → type *Kalyan* and *Thane* → Find routes | One direct ride, 7 stops, on the Central line. No train times yet, with a note saying the timetable isn't loaded |
| Kalyan → Andheri | Change at Ghatkopar to Metro Line 1, with a short walk |
| Home → **Station to doorstep** → Going to: *Yogidham* | Walk, auto and taxi by meter (≈ ₹ amounts marked Estimate), Uber, Ola and Rapido buttons. Sort by cheapest, fastest, least walking |
| Same screen → Going to → **Pick on the map** | Drag the map, tap *Use this point*, options update |
| Open Uber from that list | Uber opens with pickup and drop filled in (if Uber is installed) |
| Map tab → *My location* | Asks permission once; shows your position. Deny it and the map still works |
| Profile → Language → मराठी / हिंदी | Whole app switches language |
| Station page (tap a station on the map → Departures) | Lines at the station; no times until the timetable is entered |
| Turn on airplane mode and reopen | Route planning, station search and the last-mile list still work; the map background and ride apps need internet |

## Not in this build (on purpose)

- **Sign-in, commuter reports, alerts, admin**: hidden until the owner sets up Firebase and the Google Sheet.
- **Train departure times**: shown only after an official timetable is entered. The app never guesses times.
- **Live vehicle positions or app prices**: no free, legal source exists. Fares are estimates from the official tariff and say so.

## Reporting a problem

Send the owner: phone model and Android version, what you tapped, what you expected, what happened, and a screenshot. If a number looks wrong (fare, stop count, distance), say which two places you chose.
