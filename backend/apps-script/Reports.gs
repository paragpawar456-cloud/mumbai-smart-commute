/**
 * Community reports: short-lived notes from commuters ("long queue at the
 * west auto stand", "stand moved"). Shown as Community, never as fact.
 * The reporter's uid is stored for abuse handling but never returned by the
 * public list. Each report expires; moderators can approve or reject.
 */
var REPORT_TYPES = ['queue', 'no_vehicles', 'stand_moved', 'stop_issue', 'closure', 'disruption'];
var REPORT_EXPIRY_DEFAULT_MIN = {
  queue: 30, no_vehicles: 30, disruption: 120, closure: 1440, stop_issue: 10080, stand_moved: 10080,
};

function reportExpiryMinutes_(type) {
  var v = Number(configValue_('report_expiry_minutes_' + type));
  return v > 0 ? v : REPORT_EXPIRY_DEFAULT_MIN[type];
}

function coord_(v, field, min, max) {
  var n = Number(v);
  if (typeof v !== 'number' || !isFinite(n) || n < min || n > max) {
    throw new ApiError('invalid_input', field + ' is outside the Mumbai region');
  }
  return Math.round(n * 10000) / 10000; // ~11 m; enough to find a stand, not a home
}

function uidTag_(uid) {
  return Utilities.base64EncodeWebSafe(
    Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, 'corr:' + uid)).slice(0, 12);
}

/** Bumped on every change so cached lists never hide a new report. */
function reportsGen_() { return CacheService.getScriptCache().get('rep:gen') || '0'; }
function bumpReportsGen_() { CacheService.getScriptCache().put('rep:gen', String(Date.now()), 21600); }

function isLive_(r, nowIso) {
  return (r.status === 'pending' || r.status === 'approved') && String(r.expires_at) > nowIso;
}

function publicReport_(r) {
  return {
    reportId: r.report_id, type: r.type, targetId: r.target_id || null,
    lat: Number(r.lat), lng: Number(r.lng), note: r.note || '', status: r.status,
    createdAt: r.created_at, expiresAt: r.expires_at, corroborations: Number(r.corroborations) || 0,
  };
}

function handleSubmitReport(ctx) {
  var p = ctx.payload;
  var type = Validate.oneOf(p.type, 'type', REPORT_TYPES);
  var targetId = Validate.string(p.targetId, 'targetId', { max: 64 });
  var lat = coord_(p.lat, 'lat', 18.8, 19.9);
  var lng = coord_(p.lng, 'lng', 72.7, 73.5);
  var note = Validate.string(p.note, 'note', { max: 200 });
  var now = new Date();
  var nowIso = now.toISOString();
  return Db.withLock(function () {
    var mine = Db.all('CommunityReports').filter(function (r) { return r.uid === ctx.user.uid && isLive_(r, nowIso); });
    if (mine.length >= 5) throw new ApiError('rate_limited', 'You have 5 active reports; wait for some to expire');
    var dup = mine.filter(function (r) { return r.type === type && String(r.target_id) === targetId; })[0];
    if (dup) throw new ApiError('duplicate', 'You already reported this');
    var row = {
      report_id: 'R' + now.getTime().toString(36) + Math.floor(Math.random() * 1e6).toString(36),
      uid: ctx.user.uid, type: type, target_id: targetId, lat: lat, lng: lng, note: note,
      status: 'pending', created_at: nowIso,
      expires_at: new Date(now.getTime() + reportExpiryMinutes_(type) * 60000).toISOString(),
      corroborations: 0, corroborated_by: '', moderated_by: '', moderated_at: '',
    };
    Db.append('CommunityReports', row);
    bumpReportsGen_();
    return { report: publicReport_(row) };
  });
}

/** Public: live reports within radiusKm (max 5) of a point. No uids. */
function handleListReports(ctx) {
  var p = ctx.payload;
  var lat = coord_(p.lat, 'lat', 18.8, 19.9);
  var lng = coord_(p.lng, 'lng', 72.7, 73.5);
  var radiusKm = p.radiusKm === undefined ? 2 : Number(p.radiusKm);
  if (!(radiusKm > 0 && radiusKm <= 5)) throw new ApiError('invalid_input', 'radiusKm must be 0–5');
  // Cell-level cache: everyone near the same station shares one Sheet read a minute.
  var key = 'rep:' + reportsGen_() + ':' + lat.toFixed(2) + ':' + lng.toFixed(2) + ':' + radiusKm;
  var cache = CacheService.getScriptCache();
  var hit = cache.get(key);
  if (hit) return JSON.parse(hit);
  var nowIso = new Date().toISOString();
  var out = Db.all('CommunityReports')
    .filter(function (r) { return isLive_(r, nowIso) && kmBetween_(lat, lng, Number(r.lat), Number(r.lng)) <= radiusKm; })
    .sort(function (a, b) { return String(b.created_at).localeCompare(String(a.created_at)); })
    .slice(0, 50)
    .map(publicReport_);
  var res = { reports: out, asOf: nowIso };
  cache.put(key, JSON.stringify(res), 60);
  return res;
}

function handleCorroborateReport(ctx) {
  var id = Validate.string(ctx.payload.reportId, 'reportId', { required: true, max: 40 });
  var tag = uidTag_(ctx.user.uid);
  return Db.withLock(function () {
    var r = Db.findOne('CommunityReports', 'report_id', id);
    if (!r || !isLive_(r, new Date().toISOString())) throw new ApiError('not_found', 'Report not found or expired');
    if (r.uid === ctx.user.uid) throw new ApiError('invalid_input', 'You cannot confirm your own report');
    var by = String(r.corroborated_by || '').split(',').filter(String);
    if (by.indexOf(tag) !== -1) throw new ApiError('duplicate', 'Already confirmed');
    by.push(tag);
    var n = (Number(r.corroborations) || 0) + 1;
    Db.update('CommunityReports', r._row, { corroborations: n, corroborated_by: by.slice(-50).join(',') });
    bumpReportsGen_();
    return { reportId: id, corroborations: n };
  });
}

function handleModListReports(ctx) {
  var status = ctx.payload.status
    ? Validate.oneOf(ctx.payload.status, 'status', ['pending', 'approved', 'rejected', 'expired']) : 'pending';
  var nowIso = new Date().toISOString();
  var rows = Db.all('CommunityReports').filter(function (r) {
    var expired = r.status === 'expired' || ((r.status === 'pending' || r.status === 'approved') && String(r.expires_at) <= nowIso);
    return status === 'expired' ? expired : r.status === status && !expired;
  });
  rows.sort(function (a, b) { return String(b.created_at).localeCompare(String(a.created_at)); });
  return {
    reports: rows.slice(0, 100).map(function (r) {
      var o = publicReport_(r);
      o.reporter = r.uid; // moderators only, for abuse handling
      o.moderatedBy = r.moderated_by || null;
      return o;
    }),
  };
}

function handleModerateReport(ctx) {
  var id = Validate.string(ctx.payload.reportId, 'reportId', { required: true, max: 40 });
  var decision = Validate.oneOf(ctx.payload.decision, 'decision', ['approved', 'rejected']);
  return Db.withLock(function () {
    var r = Db.findOne('CommunityReports', 'report_id', id);
    if (!r) throw new ApiError('not_found', 'Report not found');
    Db.update('CommunityReports', r._row, {
      status: decision, moderated_by: ctx.user.uid, moderated_at: new Date().toISOString(),
    });
    audit_(ctx.user.uid, 'moderate_report', id, decision);
    bumpReportsGen_();
    return { reportId: id, status: decision };
  });
}

/**
 * Marks past-expiry reports as expired. Optional: add a time-driven trigger
 * (hourly) in the Apps Script editor; reads already ignore expired rows.
 */
function expireReports() {
  var nowIso = new Date().toISOString();
  Db.withLock(function () {
    Db.all('CommunityReports').forEach(function (r) {
      if ((r.status === 'pending' || r.status === 'approved') && String(r.expires_at) <= nowIso) {
        Db.update('CommunityReports', r._row, { status: 'expired' });
      }
    });
  });
}

function kmBetween_(lat1, lng1, lat2, lng2) {
  function rad(d) { return d * Math.PI / 180; }
  var dLat = rad(lat2 - lat1), dLng = rad(lng2 - lng1);
  var h = Math.pow(Math.sin(dLat / 2), 2) +
    Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.pow(Math.sin(dLng / 2), 2);
  return 2 * 6371 * Math.asin(Math.sqrt(h));
}
