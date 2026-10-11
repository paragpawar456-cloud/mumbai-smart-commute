/**
 * Data pack: the public transit data the app downloads in one go.
 * Built from the Sheet, validated, then published by bumping
 * AppConfiguration.data_pack_version. The app only downloads when that
 * version is newer than the one it has, so normal use costs almost nothing.
 *
 * tablesToPack_ and validatePack_ are pure (no Apps Script services) so the
 * Node CSV checker in tool/ can reuse them.
 */
var PACK_TABLES = ['Stations', 'TrainRoutes', 'Interchanges', 'TrainTrips', 'TripStopTimes', 'DataSources',
                   'Places', 'PickupPoints', 'BusStops', 'BusRoutes', 'FareRules', 'TransportProviders'];
var SERVICE_DAYS = ['DAILY', 'MON-SAT', 'MON-FRI', 'SAT', 'SUN', 'HOL'];

function tablesToPack_(t, version, generatedAt) {
  function rows(name) { return t[name] || []; }
  function num(v) { return v === '' || v === null || v === undefined ? null : Number(v); }
  function truthy(v) { return v === true || String(v).trim().toUpperCase() === 'TRUE'; }
  function str(v) { return v === null || v === undefined ? '' : String(v).trim(); }
  function pick(rows, cols) {
    return rows.map(function (r) {
      var o = {};
      cols.forEach(function (c) { o[c] = r[c] instanceof Date ? r[c].toISOString().slice(0, 10) : r[c]; });
      return o;
    });
  }
  function hhmm(v) {
    if (v instanceof Date) { // Sheets turns "08:05" into a time value
      return ('0' + v.getHours()).slice(-2) + ':' + ('0' + v.getMinutes()).slice(-2);
    }
    return str(v);
  }
  return {
    version: Number(version),
    generated_at: generatedAt,
    sources: pick(t.DataSources, ['source_id', 'name', 'licence', 'attribution', 'url']),
    stations: pick(t.Stations, ['station_id', 'name_en', 'name_mr', 'name_hi', 'modes', 'lat', 'lng', 'source_id'])
      .map(function (s) { s.lat = Number(s.lat); s.lng = Number(s.lng); return s; }),
    lines: pick(t.TrainRoutes, ['route_id', 'operator', 'mode', 'name_en', 'color', 'station_sequence', 'source_id']),
    interchanges: pick(t.Interchanges, ['from_station_id', 'to_station_id', 'walk_minutes'])
      .map(function (i) { i.walk_minutes = Number(i.walk_minutes); return i; }),
    trips: pick(t.TrainTrips, ['trip_id', 'route_id', 'train_number', 'direction', 'service_days',
                               'train_type', 'ac', 'ladies_special', 'valid_from', 'valid_to', 'source_id'])
      .map(function (x) {
        x.ac = x.ac === true || str(x.ac).toUpperCase() === 'TRUE';
        x.ladies_special = x.ladies_special === true || str(x.ladies_special).toUpperCase() === 'TRUE';
        x.train_number = str(x.train_number);
        return x;
      }),
    stop_times: t.TripStopTimes.map(function (r) {
      return [str(r.trip_id), Number(r.seq), str(r.station_id), hhmm(r.arrival) || null, hhmm(r.departure), str(r.platform) || null];
    }),
    places: pick(rows('Places'), ['place_id', 'name_en', 'name_mr', 'name_hi', 'kind', 'lat', 'lng', 'near_station_id', 'source_id'])
      .map(function (x) { x.lat = num(x.lat); x.lng = num(x.lng); return x; }),
    pickup_points: pick(rows('PickupPoints'), ['pickup_id', 'kind', 'name_en', 'lat', 'lng', 'near_station_id', 'destinations',
                                               'shared_fare_inr', 'fare_source', 'verification', 'verified_at', 'source_id'])
      .map(function (x) { x.lat = num(x.lat); x.lng = num(x.lng); x.shared_fare_inr = num(x.shared_fare_inr); return x; }),
    bus_stops: pick(rows('BusStops'), ['stop_id', 'name_en', 'name_mr', 'lat', 'lng', 'operators', 'source_id'])
      .map(function (x) { x.lat = num(x.lat); x.lng = num(x.lng); return x; }),
    bus_routes: pick(rows('BusRoutes'), ['bus_route_id', 'operator', 'route_number', 'name_en', 'stop_sequence',
                                         'frequency_note', 'first_departure', 'last_departure', 'source_id'])
      .map(function (x) {
        x.route_number = str(x.route_number);
        x.first_departure = hhmm(x.first_departure);
        x.last_departure = hhmm(x.last_departure);
        return x;
      }),
    fare_rules: pick(rows('FareRules'), ['fare_rule_id', 'mode', 'region', 'min_fare_inr', 'min_km', 'per_km_inr',
                                         'night_multiplier', 'night_start', 'night_end', 'effective_from', 'source_id'])
      .map(function (x) {
        ['min_fare_inr', 'min_km', 'per_km_inr', 'night_multiplier'].forEach(function (k) { x[k] = num(x[k]); });
        x.night_start = hhmm(x.night_start);
        x.night_end = hhmm(x.night_end);
        return x;
      }),
    providers: rows('TransportProviders').filter(function (r) { return truthy(r.active); }).map(function (r) {
      return {
        provider_id: str(r.provider_id), name: str(r.name), categories: str(r.categories),
        integration: str(r.integration), android_package: str(r.android_package), link_template: str(r.link_template),
      };
    }),
  };
}

/** Returns a list of human-readable problems; empty means publishable. */
function validatePack_(p) {
  var errors = [];
  function err(m) { if (errors.length < 200) errors.push(m); }
  var TIME = /^([0-2]?\d|3[0-1]):[0-5]\d$/;

  var stations = {};
  p.stations.forEach(function (s) {
    if (!s.station_id) err('Station with empty station_id');
    if (stations[s.station_id]) err('Duplicate station_id ' + s.station_id);
    stations[s.station_id] = s;
    if (!s.name_en) err('Station ' + s.station_id + ' has no name_en');
    // Rough Maharashtra bounding box catches swapped or missing coordinates.
    if (!(s.lat > 15.5 && s.lat < 22.1 && s.lng > 72.5 && s.lng < 80.9)) {
      err('Station ' + s.station_id + ' coordinates look wrong (' + s.lat + ', ' + s.lng + ')');
    }
    if (!s.source_id) err('Station ' + s.station_id + ' has no source_id');
  });

  var lines = {};
  p.lines.forEach(function (l) {
    if (lines[l.route_id]) err('Duplicate route_id ' + l.route_id);
    var seq = String(l.station_sequence || '').split(',').map(function (x) { return x.trim(); }).filter(String);
    lines[l.route_id] = seq;
    if (['suburban', 'metro', 'mono'].indexOf(l.mode) === -1) err('Route ' + l.route_id + ' has invalid mode ' + l.mode);
    if (seq.length < 2) err('Route ' + l.route_id + ' needs at least 2 stations');
    seq.forEach(function (id) { if (!stations[id]) err('Route ' + l.route_id + ' uses unknown station ' + id); });
  });

  p.interchanges.forEach(function (i) {
    if (!stations[i.from_station_id] || !stations[i.to_station_id]) {
      err('Interchange ' + i.from_station_id + '→' + i.to_station_id + ' uses unknown station');
    }
    if (!(i.walk_minutes >= 1 && i.walk_minutes <= 30)) err('Interchange walk_minutes out of range');
  });

  var trips = {};
  p.trips.forEach(function (t) {
    if (trips[t.trip_id]) err('Duplicate trip_id ' + t.trip_id);
    trips[t.trip_id] = t;
    if (!lines[t.route_id]) err('Trip ' + t.trip_id + ' uses unknown route ' + t.route_id);
    if (['up', 'down'].indexOf(t.direction) === -1) err('Trip ' + t.trip_id + ' direction must be up or down');
    if (SERVICE_DAYS.indexOf(String(t.service_days).toUpperCase()) === -1) err('Trip ' + t.trip_id + ' has invalid service_days');
    if (!/^\d{4}-\d{2}-\d{2}/.test(String(t.valid_from))) err('Trip ' + t.trip_id + ' needs valid_from (YYYY-MM-DD)');
    if (!t.source_id) err('Trip ' + t.trip_id + ' has no source_id (which official timetable?)');
  });

  var byTrip = {};
  p.stop_times.forEach(function (r) {
    var tripId = r[0];
    if (!trips[tripId]) { err('Stop time for unknown trip ' + tripId); return; }
    if (!stations[r[2]]) err('Trip ' + tripId + ' stops at unknown station ' + r[2]);
    if (!TIME.test(r[4] || '')) err('Trip ' + tripId + ' seq ' + r[1] + ' has bad departure "' + r[4] + '"');
    if (r[3] && !TIME.test(r[3])) err('Trip ' + tripId + ' seq ' + r[1] + ' has bad arrival "' + r[3] + '"');
    (byTrip[tripId] = byTrip[tripId] || []).push(r);
  });

  function mins(s) { var a = s.split(':'); return Number(a[0]) * 60 + Number(a[1]); }
  validateLastMile_(p, stations, err);
  Object.keys(trips).forEach(function (id) {
    var rows = (byTrip[id] || []).slice().sort(function (a, b) { return a[1] - b[1]; });
    if (rows.length < 2) { err('Trip ' + id + ' has fewer than 2 stops'); return; }
    var seq = lines[trips[id].route_id] || [];
    var lastIdx = -1, dir = 0, lastTime = -1;
    rows.forEach(function (r, k) {
      if (k > 0 && r[1] === rows[k - 1][1]) err('Trip ' + id + ' repeats seq ' + r[1]);
      var idx = seq.indexOf(r[2]);
      if (idx === -1) err('Trip ' + id + ' stops at ' + r[2] + ' which is not on route ' + trips[id].route_id);
      if (lastIdx !== -1 && idx !== -1) {
        var d = idx > lastIdx ? 1 : -1;
        if (dir !== 0 && d !== dir) err('Trip ' + id + ' changes direction at ' + r[2]);
        dir = d;
      }
      if (idx !== -1) lastIdx = idx;
      var arr = r[3] ? mins(r[3]) : null, dep = TIME.test(r[4] || '') ? mins(r[4]) : null;
      if (arr !== null && dep !== null && dep < arr) err('Trip ' + id + ' departs ' + r[2] + ' before it arrives');
      var t = arr !== null ? arr : dep;
      if (t !== null && t < lastTime) err('Trip ' + id + ' goes back in time at ' + r[2]);
      if (dep !== null) lastTime = dep;
    });
  });
  return errors;
}

function validateLastMile_(p, stations, err) {
  var HHMM = /^([01]?\d|2[0-3]):[0-5]\d$/;
  function inMmr(x) { return x.lat > 18.8 && x.lat < 19.9 && x.lng > 72.7 && x.lng < 73.5; }
  function unique(list, key, label) {
    var seen = {};
    (list || []).forEach(function (x) {
      if (!x[key]) err(label + ' with empty ' + key);
      else if (seen[x[key]]) err('Duplicate ' + key + ' ' + x[key]);
      seen[x[key]] = x;
    });
    return seen;
  }

  unique(p.places, 'place_id', 'Place');
  (p.places || []).forEach(function (x) {
    if (!x.name_en) err('Place ' + x.place_id + ' has no name_en');
    if (!inMmr(x)) err('Place ' + x.place_id + ' is outside Mumbai region (' + x.lat + ', ' + x.lng + ')');
    if (x.near_station_id && !stations[x.near_station_id]) err('Place ' + x.place_id + ' uses unknown station ' + x.near_station_id);
    if (!x.source_id) err('Place ' + x.place_id + ' has no source_id');
  });

  unique(p.pickup_points, 'pickup_id', 'Pickup point');
  (p.pickup_points || []).forEach(function (x) {
    var id = 'Pickup ' + x.pickup_id;
    if (['auto_stand', 'shared_auto', 'taxi_stand', 'ride_pickup'].indexOf(x.kind) === -1) err(id + ' has invalid kind ' + x.kind);
    if (['admin_verified', 'osm', 'community'].indexOf(x.verification) === -1) err(id + ' has invalid verification');
    if (!inMmr(x)) err(id + ' is outside Mumbai region');
    if (x.near_station_id && !stations[x.near_station_id]) err(id + ' uses unknown station ' + x.near_station_id);
    if (x.shared_fare_inr !== null && x.shared_fare_inr !== undefined) {
      if (!(x.shared_fare_inr > 0 && x.shared_fare_inr < 500)) err(id + ' shared fare out of range');
      if (!x.fare_source) err(id + ' has a shared fare but no fare_source');
    }
    if (!x.source_id) err(id + ' has no source_id');
  });

  var stops = unique(p.bus_stops, 'stop_id', 'Bus stop');
  (p.bus_stops || []).forEach(function (x) {
    if (!inMmr(x)) err('Bus stop ' + x.stop_id + ' is outside Mumbai region');
  });
  unique(p.bus_routes, 'bus_route_id', 'Bus route');
  (p.bus_routes || []).forEach(function (r) {
    var seq = String(r.stop_sequence || '').split(',').map(function (s) { return s.trim(); }).filter(String);
    if (seq.length < 2) err('Bus route ' + r.bus_route_id + ' needs at least 2 stops');
    seq.forEach(function (s) { if (!stops[s]) err('Bus route ' + r.bus_route_id + ' uses unknown stop ' + s); });
    ['first_departure', 'last_departure'].forEach(function (k) {
      if (r[k] && !HHMM.test(r[k])) err('Bus route ' + r.bus_route_id + ' has bad ' + k);
    });
    if (!r.source_id) err('Bus route ' + r.bus_route_id + ' has no source_id');
  });

  unique(p.fare_rules, 'fare_rule_id', 'Fare rule');
  (p.fare_rules || []).forEach(function (f) {
    var id = 'Fare rule ' + f.fare_rule_id;
    if (['auto', 'taxi', 'suburban', 'metro', 'bus'].indexOf(f.mode) === -1) err(id + ' has invalid mode');
    if (!(f.min_fare_inr > 0)) err(id + ' needs min_fare_inr');
    if (!(f.min_km >= 0)) err(id + ' needs min_km');
    if (f.per_km_inr !== null && !(f.per_km_inr > 0)) err(id + ' per_km_inr must be positive');
    if (f.night_multiplier !== null) {
      if (!(f.night_multiplier >= 1 && f.night_multiplier <= 2)) err(id + ' night_multiplier should be 1–2');
      if (!HHMM.test(f.night_start || '') || !HHMM.test(f.night_end || '')) err(id + ' needs night_start and night_end');
    }
    if (!/^\d{4}-\d{2}-\d{2}/.test(String(f.effective_from))) err(id + ' needs effective_from (YYYY-MM-DD)');
    if (!f.source_id) err(id + ' has no source_id (official notification)');
  });

  unique(p.providers, 'provider_id', 'Provider');
  (p.providers || []).forEach(function (x) {
    if (['deep_link', 'open_app', 'none'].indexOf(x.integration) === -1) err('Provider ' + x.provider_id + ' has invalid integration');
    if (x.integration === 'deep_link' && !/^https:\/\//.test(x.link_template)) err('Provider ' + x.provider_id + ' deep link must be https');
    if (x.integration === 'open_app' && !/^[a-z][\w.]+$/.test(x.android_package)) err('Provider ' + x.provider_id + ' needs android_package');
  });
}

/* ---------- Apps Script side ---------- */

function readPackTables_() {
  var t = {};
  PACK_TABLES.forEach(function (name) { t[name] = Db.all(name); });
  return t;
}

function configValue_(key) {
  var r = Db.findOne('AppConfiguration', 'key', key);
  return r ? String(r.value) : '';
}

/** Cached per version in 90 KB chunks (CacheService caps a value at 100 KB). */
function getPublishedPackJson_() {
  var version = configValue_('data_pack_version');
  if (version === '0' || version === '') return null;
  var cache = CacheService.getScriptCache();
  var head = cache.get('pack:' + version + ':n');
  if (head) {
    var keys = [];
    for (var i = 0; i < Number(head); i++) keys.push('pack:' + version + ':' + i);
    var parts = cache.getAll(keys);
    if (Object.keys(parts).length === keys.length) {
      return keys.map(function (k) { return parts[k]; }).join('');
    }
  }
  var json = JSON.stringify(tablesToPack_(readPackTables_(), version, configValue_('data_pack_generated_at')));
  var chunks = {}, n = 0;
  for (var off = 0; off < json.length; off += 90000) chunks['pack:' + version + ':' + n++] = json.slice(off, off + 90000);
  chunks['pack:' + version + ':n'] = String(n);
  try { cache.putAll(chunks, 21600); } catch (e) { console.warn('Pack cache skipped: ' + e); }
  return json;
}

function handleGetDataPack(ctx) {
  var have = Number(ctx.payload.haveVersion || 0);
  var version = Number(configValue_('data_pack_version') || 0);
  if (!version || have >= version) return { unchanged: true, version: version };
  return { pack: JSON.parse(getPublishedPackJson_()) };
}

/** Owner-only: run from the Sheet menu. Validates, then bumps the version. */
function publishDataPack() {
  var ui = SpreadsheetApp.getUi();
  var started = new Date().toISOString();
  var tables = readPackTables_();
  var errors = validatePack_(tablesToPack_(tables, 0, started));
  var rows = PACK_TABLES.reduce(function (n, k) { return n + tables[k].length; }, 0);
  recordSync_('data_pack', started, errors.length ? null : started, rows, errors);
  if (errors.length) {
    ui.alert('Not published: ' + errors.length + ' problem(s)\n\n' + errors.slice(0, 20).join('\n'));
    return;
  }
  Db.withLock(function () {
    var v = Db.findOne('AppConfiguration', 'key', 'data_pack_version');
    var g = Db.findOne('AppConfiguration', 'key', 'data_pack_generated_at');
    Db.update('AppConfiguration', v._row, { value: String(Number(v.value || 0) + 1), updated_at: started });
    Db.update('AppConfiguration', g._row, { value: started, updated_at: started });
  });
  ui.alert('Published data pack version ' + configValue_('data_pack_version') + ' (' + rows + ' rows).');
}

function validateDataOnly() {
  var errors = validatePack_(tablesToPack_(readPackTables_(), 0, new Date().toISOString()));
  SpreadsheetApp.getUi().alert(errors.length ? errors.slice(0, 30).join('\n') : 'No problems found.');
}

function recordSync_(sourceId, attemptAt, successAt, rows, errors) {
  var patch = {
    source_id: sourceId, last_attempt_at: attemptAt, retrieved: rows, parsed: rows,
    accepted: errors.length ? 0 : rows, rejected: errors.length ? rows : 0,
    last_error: errors.length ? errors[0] : '',
  };
  if (successAt) patch.last_success_at = successAt;
  var existing = Db.findOne('SyncStatus', 'source_id', sourceId);
  if (existing) Db.update('SyncStatus', existing._row, patch); else Db.append('SyncStatus', patch);
}

function onOpen() {
  SpreadsheetApp.getUi().createMenu('Mumbai Smart Commute')
    .addItem('Check data for problems', 'validateDataOnly')
    .addItem('Publish data pack to the app', 'publishDataPack')
    .addSeparator()
    .addItem('Set up / repair tabs', 'setupSheets')
    .addToUi();
}
