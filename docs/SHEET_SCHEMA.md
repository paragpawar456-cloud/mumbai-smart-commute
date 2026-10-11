# Google Sheet schema

Generated from `backend/apps-script/Schema.gs` by `npm run schema-doc` (in `backend/`). Do not edit by hand.

The Sheet is private to the owner. The app never reads it directly; every read and write goes through the Apps Script API.

## Users

Access: server only; admin read via API. Primary key: `uid`.

| Column | Type | Required | Notes |
|---|---|---|---|
| uid | id | yes | Firebase UID (primary key) |
| email | string | yes | From verified Firebase token, never client input |
| display_name | string |  | max 60 chars |
| preferred_language | enum(en|mr|hi) | yes | default en |
| role | enum(user|moderator|admin) | yes | only changed by admin; never from client |
| status | enum(active|disabled|deleted) | yes |  |
| consent_version | string |  | privacy policy version accepted |
| created_at | datetime | yes | ISO 8601 UTC |
| updated_at | datetime | yes |  |
| last_seen_at | datetime |  | day resolution only |

## Stations

Access: public read (data pack); admin write. Primary key: `station_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| station_id | id | yes | stable code, e.g. KYN, CSMT |
| name_en | string | yes |  |
| name_mr | string |  |  |
| name_hi | string |  |  |
| modes | string | yes | comma list: suburban,metro,mono |
| lat | number | yes |  |
| lng | number | yes |  |
| facilities | json |  | {"lift":true,...} only when verified |
| source_id | id | yes | FK DataSources |
| verified_at | datetime |  |  |

## TrainRoutes

Access: public read; admin write. Primary key: `route_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| route_id | id | yes | e.g. CR-MAIN, WR, HR, THR |
| operator | string | yes | CR/WR/MMRCL/MMOPL/MMRDA |
| mode | enum(suburban|metro|mono) | yes |  |
| name_en | string | yes |  |
| color | string |  | #RRGGBB |
| station_sequence | string | yes | ordered station_ids, comma separated |
| source_id | id | yes |  |

## TrainTrips

Access: public read; admin write. Primary key: `trip_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| trip_id | id | yes |  |
| route_id | id | yes | FK TrainRoutes |
| train_number | string |  |  |
| direction | enum(up|down) | yes |  |
| service_days | string | yes | e.g. MON-SAT, SUN, HOL |
| train_type | enum(slow|fast|semi_fast) | yes |  |
| ac | bool | yes |  |
| ladies_special | bool | yes |  |
| cars | int |  | 12/15 |
| valid_from | datetime | yes | timetable effective date |
| valid_to | datetime |  |  |
| source_id | id | yes |  |

## TripStopTimes

Access: public read; admin write. Primary key: `trip_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| trip_id | id | yes | FK TrainTrips |
| seq | int | yes |  |
| station_id | id | yes | FK Stations |
| arrival | string |  | HH:MM (24h, may exceed 24:00) |
| departure | string | yes | HH:MM |
| platform | string |  | only when verified |

## Interchanges

Access: public read; admin write. Primary key: `from_station_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| from_station_id | id | yes | FK Stations |
| to_station_id | id | yes | FK Stations; walking transfer between different stations |
| walk_minutes | int | yes | 1-30 |
| source_id | id | yes |  |

## Places

Access: public read; admin write. Primary key: `place_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| place_id | id | yes | e.g. P-YOGIDHAM |
| name_en | string | yes |  |
| name_mr | string |  |  |
| name_hi | string |  |  |
| kind | string | yes | housing, suburb, landmark, ... |
| lat | number | yes |  |
| lng | number | yes |  |
| near_station_id | id |  | FK Stations; default station for the finder |
| source_id | id | yes |  |

## BusRoutes

Access: public read; admin write. Primary key: `bus_route_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| bus_route_id | id | yes | operator:number, e.g. KDMT:12 |
| operator | enum(BEST|KDMT|TMT|NMMT|MBMT|VVMT|MSRTC) | yes |  |
| route_number | string | yes |  |
| name_en | string | yes |  |
| stop_sequence | string | yes | ordered stop_ids |
| frequency_note | string |  | e.g. every 15-20 min (published) |
| first_departure | string |  | HH:MM |
| last_departure | string |  | HH:MM |
| source_id | id | yes |  |

## BusStops

Access: public read; admin write. Primary key: `stop_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| stop_id | id | yes |  |
| name_en | string | yes |  |
| name_mr | string |  |  |
| lat | number | yes |  |
| lng | number | yes |  |
| operators | string |  | comma list |
| source_id | id | yes | e.g. BMC open data, OSM |

## PickupPoints

Access: public read; admin write. Primary key: `pickup_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| pickup_id | id | yes |  |
| kind | enum(auto_stand|shared_auto|taxi_stand|ride_pickup) | yes | a place, never a vehicle |
| name_en | string | yes |  |
| lat | number | yes |  |
| lng | number | yes |  |
| near_station_id | id |  |  |
| destinations | string |  | shared autos: served areas |
| shared_fare_inr | number |  | only if verified; see fare_source |
| fare_source | string |  |  |
| verification | enum(admin_verified|osm|community) | yes |  |
| verified_at | datetime |  |  |
| source_id | id | yes |  |

## TransportProviders

Access: public read; admin write. Primary key: `provider_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| provider_id | id | yes | uber, ola, rapido, ... |
| name | string | yes |  |
| categories | string | yes | auto,bike,cab |
| integration | enum(deep_link|open_app|none) | yes | no scraped prices |
| android_package | string |  |  |
| link_template | string |  | with {plat},{plng},{dlat},{dlng} |
| active | bool | yes |  |
| source_id | id |  | where the link format is documented |

## FareRules

Access: public read; admin write. Primary key: `fare_rule_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| fare_rule_id | id | yes |  |
| mode | enum(auto|taxi|suburban|metro|bus) | yes |  |
| region | string | yes | e.g. MMR |
| min_fare_inr | number | yes |  |
| min_km | number | yes | distance covered by min fare |
| per_km_inr | number |  |  |
| night_multiplier | number |  |  |
| night_start | string |  | HH:MM |
| night_end | string |  | HH:MM |
| slab_json | json |  | distance slabs for rail/bus |
| effective_from | datetime | yes |  |
| source_id | id | yes | official notification |

## CommunityReports

Access: signed-in users create; public read of approved/pending (no uid); moderators update. Primary key: `report_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| report_id | id | yes |  |
| uid | id | yes | never exposed publicly |
| type | enum(queue|no_vehicles|stand_moved|stop_issue|closure|disruption) | yes |  |
| target_id | id |  | pickup_id / stop_id / station_id |
| lat | number | yes | rounded to 4 dp |
| lng | number | yes |  |
| note | string |  | max 200 chars, sanitized |
| status | enum(pending|approved|rejected|expired) | yes |  |
| created_at | datetime | yes |  |
| expires_at | datetime | yes | per type, e.g. queue 30 min |
| corroborations | int | yes |  |
| corroborated_by | string |  | uid hashes, server only; one per user |
| moderated_by | id |  |  |
| moderated_at | datetime |  |  |

## ServiceAlerts

Access: public read; admin write. Primary key: `alert_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| alert_id | id | yes |  |
| scope | string | yes | route_id / station_id / ALL |
| severity | enum(info|minor|major) | yes |  |
| title_en | string | yes |  |
| title_mr | string |  |  |
| title_hi | string |  |  |
| body_en | string |  |  |
| starts_at | datetime | yes |  |
| ends_at | datetime |  |  |
| source_url | string | yes | official announcement |
| created_by | id | yes |  |

## SavedRoutes

Access: owner only. Primary key: `saved_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| saved_id | id | yes |  |
| uid | id | yes |  |
| label | string | yes | max 40 chars |
| from_json | json | yes | {name,lat,lng,station_id?} |
| to_json | json | yes |  |
| trips_per_week | int |  | for cost calculator |
| created_at | datetime | yes |  |

## AdminAuditLog

Access: append only; admin read. Primary key: `at`.

| Column | Type | Required | Notes |
|---|---|---|---|
| at | datetime | yes |  |
| actor_uid | id | yes |  |
| action | string | yes |  |
| target | string |  |  |
| detail | string |  | no personal data |

## DataSources

Access: public read (attribution); admin write. Primary key: `source_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| source_id | id | yes |  |
| name | string | yes |  |
| url | string |  |  |
| licence | string | yes | e.g. ODbL, public domain |
| attribution | string |  | text shown in app |
| update_frequency | string |  |  |
| notes | string |  |  |

## SyncStatus

Access: admin read; server write. Primary key: `source_id`.

| Column | Type | Required | Notes |
|---|---|---|---|
| source_id | id | yes |  |
| last_attempt_at | datetime |  |  |
| last_success_at | datetime |  |  |
| retrieved | int |  |  |
| parsed | int |  |  |
| accepted | int |  |  |
| rejected | int |  |  |
| displayed | int |  |  |
| last_error | string |  |  |

## AppConfiguration

Access: public keys readable; admin write. Primary key: `key`.

| Column | Type | Required | Notes |
|---|---|---|---|
| key | id | yes |  |
| value | string | yes |  |
| public | bool | yes | true = sent to the app |
| updated_at | datetime | yes |  |
