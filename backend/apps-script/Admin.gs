/**
 * Admin and moderator actions used by the in-app admin section. Every route
 * here has its role checked on the server from the Users tab (see routes_);
 * the app only hides the screens. Every change is written to AdminAuditLog.
 */
function handleAdminSetUserRole(ctx) {
  var p = ctx.payload;
  var uid = Validate.string(p.uid, 'uid', { required: true, max: 128 });
  var role = Validate.oneOf(p.role, 'role', ['user', 'moderator', 'admin']);
  // Stops the last admin from locking everyone out by demoting themselves.
  if (uid === ctx.user.uid) throw new ApiError('invalid_input', 'Cannot change your own role');
  return Db.withLock(function () {
    var target = Db.findOne('Users', 'uid', uid);
    if (!target) throw new ApiError('not_found', 'User not found');
    if (target.status === 'deleted') throw new ApiError('invalid_input', 'User deleted');
    Db.update('Users', target._row, { role: role, updated_at: new Date().toISOString() });
    audit_(ctx.user.uid, 'set_user_role', uid, role);
    return { uid: uid, role: role };
  });
}

function handleAdminOverview() {
  var users = Db.all('Users');
  var count = function (list, f) { return list.filter(f).length; };
  var nowIso = new Date().toISOString();
  var reports = Db.all('CommunityReports');
  return {
    users: {
      total: users.length,
      active: count(users, function (u) { return u.status === 'active'; }),
      disabled: count(users, function (u) { return u.status === 'disabled'; }),
      deleted: count(users, function (u) { return u.status === 'deleted'; }),
      admins: count(users, function (u) { return u.role === 'admin' && u.status === 'active'; }),
      moderators: count(users, function (u) { return u.role === 'moderator' && u.status === 'active'; }),
    },
    reports: {
      pending: count(reports, function (r) { return r.status === 'pending' && String(r.expires_at) > nowIso; }),
      live: count(reports, function (r) { return isLive_(r, nowIso); }),
    },
    alerts: { active: activeAlerts_(nowIso).length },
    dataPack: {
      version: Number(configValue_('data_pack_version') || 0),
      generatedAt: configValue_('data_pack_generated_at') || null,
    },
    sync: Db.all('SyncStatus').map(function (s) {
      return {
        sourceId: s.source_id, lastAttemptAt: s.last_attempt_at || null, lastSuccessAt: s.last_success_at || null,
        accepted: Number(s.accepted) || 0, rejected: Number(s.rejected) || 0, lastError: s.last_error || '',
      };
    }),
    roadDistanceEnabled: !!PropertiesService.getScriptProperties().getProperty('ORS_API_KEY'),
  };
}

function handleAdminListAudit(ctx) {
  var p = ctx.payload;
  var pageSize = p.pageSize ? Validate.int(p.pageSize, 'pageSize', 1, 100) : 50;
  var page = p.page ? Validate.int(p.page, 'page', 0, 10000) : 0;
  var rows = Db.all('AdminAuditLog').reverse(); // append-only, so newest last
  return {
    total: rows.length, page: page, pageSize: pageSize,
    entries: rows.slice(page * pageSize, (page + 1) * pageSize).map(function (r) {
      return { at: r.at, actor: r.actor_uid, action: r.action, target: r.target, detail: r.detail };
    }),
  };
}

/* ---------- Service alerts (official announcements, entered by admins) ---------- */

function alertsGen_() { return CacheService.getScriptCache().get('alerts:gen') || '0'; }
function bumpAlertsGen_() { CacheService.getScriptCache().put('alerts:gen', Date.now() + '.' + Math.random(), 21600); }

function activeAlerts_(nowIso) {
  return Db.all('ServiceAlerts').filter(function (a) {
    return String(a.starts_at) <= nowIso && (!a.ends_at || String(a.ends_at) > nowIso);
  });
}

function publicAlert_(a) {
  return {
    alertId: a.alert_id, scope: a.scope, severity: a.severity,
    titleEn: a.title_en, titleMr: a.title_mr || null, titleHi: a.title_hi || null,
    bodyEn: a.body_en || '', startsAt: a.starts_at, endsAt: a.ends_at || null, sourceUrl: a.source_url,
  };
}

/** Public: alerts in force now. Cached a minute; any admin change invalidates. */
function handleGetAlerts() {
  var cache = CacheService.getScriptCache();
  var key = 'alerts:' + alertsGen_();
  var hit = cache.get(key);
  if (hit) return JSON.parse(hit);
  var nowIso = new Date().toISOString();
  var res = { alerts: activeAlerts_(nowIso).map(publicAlert_), asOf: nowIso };
  cache.put(key, JSON.stringify(res), 60);
  return res;
}

function isoDate_(v, field, required) {
  if (v === undefined || v === null || v === '') {
    if (required) throw new ApiError('invalid_input', field + ' is required');
    return '';
  }
  var d = new Date(v);
  if (typeof v !== 'string' || isNaN(d.getTime())) throw new ApiError('invalid_input', field + ' must be a date');
  return d.toISOString();
}

function handleAdminSaveAlert(ctx) {
  var p = ctx.payload;
  var row = {
    scope: Validate.string(p.scope, 'scope', { required: true, max: 40 }),
    severity: Validate.oneOf(p.severity, 'severity', ['info', 'minor', 'major']),
    title_en: Validate.string(p.titleEn, 'titleEn', { required: true, max: 120 }),
    title_mr: Validate.string(p.titleMr, 'titleMr', { max: 120 }),
    title_hi: Validate.string(p.titleHi, 'titleHi', { max: 120 }),
    body_en: Validate.string(p.bodyEn, 'bodyEn', { max: 500 }),
    starts_at: isoDate_(p.startsAt, 'startsAt', true),
    ends_at: isoDate_(p.endsAt, 'endsAt', false),
    source_url: Validate.string(p.sourceUrl, 'sourceUrl', { required: true, max: 300 }),
  };
  // Alerts must point at the official announcement they came from.
  if (!/^https:\/\/[^\s]+$/.test(row.source_url)) throw new ApiError('invalid_input', 'sourceUrl must be an https link');
  if (row.ends_at && row.ends_at <= row.starts_at) throw new ApiError('invalid_input', 'endsAt must be after startsAt');
  var id = p.alertId ? Validate.string(p.alertId, 'alertId', { max: 40 }) : '';
  return Db.withLock(function () {
    if (id) {
      var existing = Db.findOne('ServiceAlerts', 'alert_id', id);
      if (!existing) throw new ApiError('not_found', 'Alert not found');
      Db.update('ServiceAlerts', existing._row, row);
    } else {
      // Time plus random suffix: two alerts saved in the same millisecond must not collide.
      do { id = 'A' + Date.now().toString(36) + Math.floor(Math.random() * 1e6).toString(36); }
      while (Db.findOne('ServiceAlerts', 'alert_id', id));
      row.alert_id = id;
      row.created_by = ctx.user.uid;
      Db.append('ServiceAlerts', row);
    }
    audit_(ctx.user.uid, p.alertId ? 'update_alert' : 'create_alert', id, row.severity + ' ' + row.scope);
    bumpAlertsGen_();
    return { alert: publicAlert_(Db.findOne('ServiceAlerts', 'alert_id', id)) };
  });
}

function handleAdminEndAlert(ctx) {
  var id = Validate.string(ctx.payload.alertId, 'alertId', { required: true, max: 40 });
  return Db.withLock(function () {
    var a = Db.findOne('ServiceAlerts', 'alert_id', id);
    if (!a) throw new ApiError('not_found', 'Alert not found');
    Db.update('ServiceAlerts', a._row, { ends_at: new Date().toISOString() });
    audit_(ctx.user.uid, 'end_alert', id, '');
    bumpAlertsGen_();
    return { alertId: id, ended: true };
  });
}

/** Admin: every alert, newest first, including ended ones. */
function handleAdminListAlerts() {
  var rows = Db.all('ServiceAlerts').map(publicAlert_);
  rows.sort(function (a, b) { return String(b.startsAt).localeCompare(String(a.startsAt)); });
  return { alerts: rows.slice(0, 100) };
}
