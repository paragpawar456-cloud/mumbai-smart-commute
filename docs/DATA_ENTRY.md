# Entering timetable and station data

The app never guesses train times. Times appear only after an official timetable is entered here and published.

## Where data lives

| Tab | What | Template |
|---|---|---|
| Stations | One row per station, with coordinates | `data/templates/Stations.csv` (38 pilot stations from OpenStreetMap) |
| TrainRoutes | Lines and their station order | `TrainRoutes.csv` (Central main line, Metro Line 1) |
| Interchanges | Walking transfers between different stations | `Interchanges.csv` |
| TrainTrips | One row per train run | `TrainTrips.csv` (empty, header only) |
| TripStopTimes | Each stop of each train | `TripStopTimes.csv` (empty, header only) |
| DataSources | Where each row came from (shown in the app) | `DataSources.csv` |

## Adding trains

1. Add a `DataSources` row for the timetable you are copying from, e.g. `cr-tt-2026-10`, "Central Railway suburban timetable, effective 1 Oct 2026", with its URL.
2. `TrainTrips`: one row per train.
   - `trip_id`: any unique code, e.g. `CR-K-0805-UP`
   - `route_id`: `CR-MAIN`
   - `direction`: `up` (towards CSMT) or `down` (towards Kalyan)
   - `service_days`: `DAILY`, `MON-SAT`, `MON-FRI`, `SAT` or `SUN` (Sunday trains also run on public holidays)
   - `train_type`: `slow`, `fast` or `semi_fast`; `ac` and `ladies_special`: `TRUE`/`FALSE`
   - `valid_from`: date the timetable takes effect (YYYY-MM-DD); `source_id`: the DataSources code
3. `TripStopTimes`: one row per stop, in order. `seq` 1, 2, 3…; `departure` as `HH:MM` (24-hour); `arrival` optional; `platform` only if officially published. Leave out stations the train doesn't stop at.
4. In the Sheet menu choose **Mumbai Smart Commute → Check data for problems**. Fix what it lists.
5. Choose **Publish data pack to the app**. Phones pick up the new version the next time the app opens.

You can also prepare CSVs on a laptop and check them first:

```bash
node backend/tool/check_csv.js path/to/folder   # same checks the server runs
```

## Refreshing station coordinates

Station coordinates come from OpenStreetMap. To refresh them, run the **OSM data extract** workflow in GitHub Actions, then `python3 tool/pack/build_seed_pack.py`, which rewrites `assets/data/seed_pack.json` and the CSV templates.

## Last-mile data (Phase 5)

| Tab | What | Template |
|---|---|---|
| Places | Destinations people search for (housing societies, areas, landmarks) | `Places.csv` (7 around Kalyan from OpenStreetMap, incl. Yogidham) |
| PickupPoints | Auto stands, shared-auto points, taxi stands | `PickupPoints.csv` (2 OSM auto stands) |
| BusStops / BusRoutes | Bus stops and the stop order of each route | header only |
| FareRules | Auto and taxi meter rates | `FareRules.csv` (MMRTA rates from 1 Sep 2026, as reported) |
| TransportProviders | Ride-hailing apps and how to open them | `TransportProviders.csv` (Uber, Ola, Rapido) |

- **Shared autos:** add a `PickupPoints` row with `kind` = `shared_auto`, the areas it serves in `destinations` (e.g. "Yogidham, Gauripada"), and the per-seat fare in `shared_fare_inr` only if you have checked it, with how in `fare_source` (e.g. "asked drivers, 12 Oct 2026"). Set `verification` = `admin_verified` and `verified_at`.
- **Fares:** when the official MMRTA tariff card is available, add a `DataSources` row for it and point the `FareRules` rows' `source_id` at it. Leave `per_km_inr` empty if you only know the minimum fare; the app then shows "from ₹X".
- **Buses:** enter stops first (with coordinates), then a `BusRoutes` row listing `stop_id`s in order in `stop_sequence`. `frequency_note` is free text from the operator's published information.
- Publish as usual. "Check data for problems" also checks these tabs (coordinates in the Mumbai region, unknown stops, fares without a source, https-only booking links).
