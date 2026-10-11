/**
 * Sheet schema. One tab per entity; row 1 is the header.
 * Column spec: [name, type, required, notes]. Types: id, string, int, number,
 * bool, datetime, enum(a|b), json, latlng (two number columns lat/lng).
 * Run setupSheets() once from the editor after binding the script to a Sheet.
 * docs/SHEET_SCHEMA.md is generated from this file (tool/gen_schema_doc.js).
 */
var SCHEMA = {
  Users: {
    access: 'server only; admin read via API',
    columns: [
      ['uid', 'id', true, 'Firebase UID (primary key)'],
      ['email', 'string', true, 'From verified Firebase token, never client input'],
      ['display_name', 'string', false, 'max 60 chars'],
      ['preferred_language', 'enum(en|mr|hi)', true, 'default en'],
      ['role', 'enum(user|moderator|admin)', true, 'only changed by admin; never from client'],
      ['status', 'enum(active|disabled|deleted)', true, ''],
      ['consent_version', 'string', false, 'privacy policy version accepted'],
      ['created_at', 'datetime', true, 'ISO 8601 UTC'],
      ['updated_at', 'datetime', true, ''],
      ['last_seen_at', 'datetime', false, 'day resolution only'],
    ],
  },
  Stations: {
    access: 'public read (data pack); admin write',
    columns: [
      ['station_id', 'id', true, 'stable code, e.g. KYN, CSMT'],
      ['name_en', 'string', true, ''],
      ['name_mr', 'string', false, ''],
      ['name_hi', 'string', false, ''],
      ['modes', 'string', true, 'comma list: suburban,metro,mono'],
      ['lat', 'number', true, ''],
      ['lng', 'number', true, ''],
      ['facilities', 'json', false, '{"lift":true,...} only when verified'],
      ['source_id', 'id', true, 'FK DataSources'],
      ['verified_at', 'datetime', false, ''],
    ],
  },
  TrainRoutes: {
    access: 'public read; admin write',
    columns: [
      ['route_id', 'id', true, 'e.g. CR-MAIN, WR, HR, THR'],
      ['operator', 'string', true, 'CR/WR/MMRCL/MMOPL/MMRDA'],
      ['mode', 'enum(suburban|metro|mono)', true, ''],
      ['name_en', 'string', true, ''],
      ['color', 'string', false, '#RRGGBB'],
      ['station_sequence', 'string', true, 'ordered station_ids, comma separated'],
      ['source_id', 'id', true, ''],
    ],
  },
  TrainTrips: {
    access: 'public read; admin write',
    columns: [
      ['trip_id', 'id', true, ''],
      ['route_id', 'id', true, 'FK TrainRoutes'],
      ['train_number', 'string', false, ''],
      ['direction', 'enum(up|down)', true, ''],
      ['service_days', 'string', true, 'e.g. MON-SAT, SUN, HOL'],
      ['train_type', 'enum(slow|fast|semi_fast)', true, ''],
      ['ac', 'bool', true, ''],
      ['ladies_special', 'bool', true, ''],
      ['cars', 'int', false, '12/15'],
      ['valid_from', 'datetime', true, 'timetable effective date'],
      ['valid_to', 'datetime', false, ''],
      ['source_id', 'id', true, ''],
    ],
  },
  TripStopTimes: {
    access: 'public read; admin write',
    columns: [
      ['trip_id', 'id', true, 'FK TrainTrips'],
      ['seq', 'int', true, ''],
      ['station_id', 'id', true, 'FK Stations'],
      ['arrival', 'string', false, 'HH:MM (24h, may exceed 24:00)'],
      ['departure', 'string', true, 'HH:MM'],
      ['platform', 'string', false, 'only when verified'],
    ],
  },
  Interchanges: {
    access: 'public read; admin write',
    columns: [
      ['from_station_id', 'id', true, 'FK Stations'],
      ['to_station_id', 'id', true, 'FK Stations; walking transfer between different stations'],
      ['walk_minutes', 'int', true, '1-30'],
      ['source_id', 'id', true, ''],
    ],
  },
  BusRoutes: {
    access: 'public read; admin write',
    columns: [
      ['bus_route_id', 'id', true, 'operator:number, e.g. KDMT:12'],
      ['operator', 'enum(BEST|KDMT|TMT|NMMT|MBMT|VVMT|MSRTC)', true, ''],
      ['route_number', 'string', true, ''],
      ['name_en', 'string', true, ''],
      ['stop_sequence', 'string', true, 'ordered stop_ids'],
      ['frequency_note', 'string', false, 'e.g. every 15-20 min (published)'],
      ['first_departure', 'string', false, 'HH:MM'],
      ['last_departure', 'string', false, 'HH:MM'],
      ['source_id', 'id', true, ''],
    ],
  },
  BusStops: {
    access: 'public read; admin write',
    columns: [
      ['stop_id', 'id', true, ''],
      ['name_en', 'string', true, ''],
      ['name_mr', 'string', false, ''],
      ['lat', 'number', true, ''],
      ['lng', 'number', true, ''],
      ['operators', 'string', false, 'comma list'],
      ['source_id', 'id', true, 'e.g. BMC open data, OSM'],
    ],
  },
  PickupPoints: {
    access: 'public read; admin write',
    columns: [
      ['pickup_id', 'id', true, ''],
      ['kind', 'enum(auto_stand|shared_auto|taxi_stand|ride_pickup)', true, 'a place, never a vehicle'],
      ['name_en', 'string', true, ''],
      ['lat', 'number', true, ''],
      ['lng', 'number', true, ''],
      ['near_station_id', 'id', false, ''],
      ['destinations', 'string', false, 'shared autos: served areas'],
      ['shared_fare_inr', 'number', false, 'only if verified; see fare_source'],
      ['fare_source', 'string', false, ''],
      ['verification', 'enum(admin_verified|osm|community)', true, ''],
      ['verified_at', 'datetime', false, ''],
      ['source_id', 'id', true, ''],
    ],
  },
  TransportProviders: {
    access: 'public read; admin write',
    columns: [
      ['provider_id', 'id', true, 'uber, ola, rapido, ...'],
      ['name', 'string', true, ''],
      ['categories', 'string', true, 'auto,bike,cab'],
      ['integration', 'enum(deep_link|open_app|none)', true, 'no scraped prices'],
      ['android_package', 'string', false, ''],
      ['link_template', 'string', false, 'with {plat},{plng},{dlat},{dlng}'],
      ['active', 'bool', true, ''],
    ],
  },
  FareRules: {
    access: 'public read; admin write',
    columns: [
      ['fare_rule_id', 'id', true, ''],
      ['mode', 'enum(auto|taxi|suburban|metro|bus)', true, ''],
      ['region', 'string', true, 'e.g. MMR'],
      ['min_fare_inr', 'number', true, ''],
      ['min_km', 'number', true, 'distance covered by min fare'],
      ['per_km_inr', 'number', false, ''],
      ['night_multiplier', 'number', false, ''],
      ['night_start', 'string', false, 'HH:MM'],
      ['night_end', 'string', false, 'HH:MM'],
      ['slab_json', 'json', false, 'distance slabs for rail/bus'],
      ['effective_from', 'datetime', true, ''],
      ['source_id', 'id', true, 'official notification'],
    ],
  },
  CommunityReports: {
    access: 'signed-in users create; public read of approved/pending (no uid); moderators update',
    columns: [
      ['report_id', 'id', true, ''],
      ['uid', 'id', true, 'never exposed publicly'],
      ['type', 'enum(queue|no_vehicles|stand_moved|stop_issue|closure|disruption)', true, ''],
      ['target_id', 'id', false, 'pickup_id / stop_id / station_id'],
      ['lat', 'number', true, 'rounded to 4 dp'],
      ['lng', 'number', true, ''],
      ['note', 'string', false, 'max 200 chars, sanitized'],
      ['status', 'enum(pending|approved|rejected|expired)', true, ''],
      ['created_at', 'datetime', true, ''],
      ['expires_at', 'datetime', true, 'per type, e.g. queue 30 min'],
      ['corroborations', 'int', true, ''],
      ['moderated_by', 'id', false, ''],
    ],
  },
  ServiceAlerts: {
    access: 'public read; admin write',
    columns: [
      ['alert_id', 'id', true, ''],
      ['scope', 'string', true, 'route_id / station_id / ALL'],
      ['severity', 'enum(info|minor|major)', true, ''],
      ['title_en', 'string', true, ''],
      ['title_mr', 'string', false, ''],
      ['title_hi', 'string', false, ''],
      ['body_en', 'string', false, ''],
      ['starts_at', 'datetime', true, ''],
      ['ends_at', 'datetime', false, ''],
      ['source_url', 'string', true, 'official announcement'],
      ['created_by', 'id', true, ''],
    ],
  },
  SavedRoutes: {
    access: 'owner only',
    columns: [
      ['saved_id', 'id', true, ''],
      ['uid', 'id', true, ''],
      ['label', 'string', true, 'max 40 chars'],
      ['from_json', 'json', true, '{name,lat,lng,station_id?}'],
      ['to_json', 'json', true, ''],
      ['trips_per_week', 'int', false, 'for cost calculator'],
      ['created_at', 'datetime', true, ''],
    ],
  },
  AdminAuditLog: {
    access: 'append only; admin read',
    columns: [
      ['at', 'datetime', true, ''],
      ['actor_uid', 'id', true, ''],
      ['action', 'string', true, ''],
      ['target', 'string', false, ''],
      ['detail', 'string', false, 'no personal data'],
    ],
  },
  DataSources: {
    access: 'public read (attribution); admin write',
    columns: [
      ['source_id', 'id', true, ''],
      ['name', 'string', true, ''],
      ['url', 'string', false, ''],
      ['licence', 'string', true, 'e.g. ODbL, public domain'],
      ['attribution', 'string', false, 'text shown in app'],
      ['update_frequency', 'string', false, ''],
      ['notes', 'string', false, ''],
    ],
  },
  SyncStatus: {
    access: 'admin read; server write',
    columns: [
      ['source_id', 'id', true, ''],
      ['last_attempt_at', 'datetime', false, ''],
      ['last_success_at', 'datetime', false, ''],
      ['retrieved', 'int', false, ''],
      ['parsed', 'int', false, ''],
      ['accepted', 'int', false, ''],
      ['rejected', 'int', false, ''],
      ['displayed', 'int', false, ''],
      ['last_error', 'string', false, ''],
    ],
  },
  AppConfiguration: {
    access: 'public keys readable; admin write',
    columns: [
      ['key', 'id', true, ''],
      ['value', 'string', true, ''],
      ['public', 'bool', true, 'true = sent to the app'],
      ['updated_at', 'datetime', true, ''],
    ],
  },
};

/** Creates missing tabs and headers. Safe to re-run; never deletes data. */
function setupSheets() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  Object.keys(SCHEMA).forEach(function (name) {
    var sheet = ss.getSheetByName(name) || ss.insertSheet(name);
    var headers = SCHEMA[name].columns.map(function (c) { return c[0]; });
    var existing = sheet.getLastColumn() > 0
      ? sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0] : [];
    if (existing.join() !== headers.join()) {
      if (existing.filter(String).length > 0 && sheet.getLastRow() > 1) {
        throw new Error('Header mismatch on ' + name + '; fix manually to avoid data loss');
      }
      sheet.getRange(1, 1, 1, headers.length).setValues([headers]).setFontWeight('bold');
      sheet.setFrozenRows(1);
    }
  });
  var defaults = ss.getSheetByName('Sheet1');
  if (defaults && ss.getSheets().length > 1 && defaults.getLastRow() === 0) ss.deleteSheet(defaults);
  seedConfig_();
}

function seedConfig_() {
  var now = new Date().toISOString();
  var rows = [
    ['data_pack_version', '0', true, now],
    ['min_app_version', '1.0.0', true, now],
    ['report_expiry_minutes_queue', '30', true, now],
    ['report_expiry_minutes_stand_moved', '10080', true, now],
    ['data_pack_generated_at', '', true, now],
  ];
  rows.forEach(function (r) {
    if (!Db.findOne('AppConfiguration', 'key', r[0])) Db.append('AppConfiguration', r);
  });
}
