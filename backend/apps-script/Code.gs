/**
 * Mumbai Smart Commute API. Deployed as a web app (execute as owner,
 * access: anyone). The app POSTs {action, payload, idToken?, requestId}.
 * Every response is {ok: true, data} or {ok: false, error: {code, message}}.
 * Apps Script always answers HTTP 200, so clients must read `ok`.
 */
function ApiError(code, message) {
  this.code = code;
  this.message = message;
}

/**
 * auth: request must carry a valid Firebase ID token.
 * roles: allowed Users.role values (checked server-side from the Sheet).
 * rate: [max calls, window seconds] per uid (or per action when anonymous).
 * write: handler mutates the Sheet; duplicate requestIds are replayed.
 *
 * Built lazily: Apps Script evaluates files in order, so a top-level object
 * here could not reference handlers declared in later files.
 */
function routes_() {
  return {
  health:          { auth: false, rate: [120, 60], handler: handleHealth },
  getConfig:       { auth: false, rate: [120, 60], handler: handleGetConfig },
  getProfile:      { auth: true,  rate: [30, 60],  handler: handleGetProfile },
  updateProfile:   { auth: true,  rate: [10, 60],  write: true, handler: handleUpdateProfile },
  deleteMyData:    { auth: true,  rate: [3, 3600], write: true, handler: handleDeleteMyData },
  adminListUsers:  { auth: true,  roles: ['admin'], rate: [60, 60], handler: handleAdminListUsers },
  adminSetUserStatus: { auth: true, roles: ['admin'], rate: [30, 60], write: true, handler: handleAdminSetUserStatus },
  };
}

function doPost(e) {
  return json_(dispatch_(e && e.postData ? e.postData.contents : ''));
}

function doGet() {
  return json_({ ok: true, data: { service: 'mumbai-smart-commute', status: 'up' } });
}

/** Separated from doPost so tests can call it without ContentService. */
function dispatch_(raw) {
  var req;
  try {
    req = JSON.parse(raw || '{}');
  } catch (err) {
    return fail_('invalid_input', 'Body must be JSON');
  }
  try {
    var table = routes_();
    var route = Object.prototype.hasOwnProperty.call(table, req.action) ? table[req.action] : null;
    if (!route) throw new ApiError('not_found', 'Unknown action');

    var ctx = { payload: req.payload || {}, principal: null, user: null };
    if (route.auth) ctx.principal = Auth.verify(req.idToken);
    var who = ctx.principal ? ctx.principal.uid : 'anon';

    // Replay before the status check so a retried deleteMyData still gets its
    // original answer. Keyed per uid so one user can't read another's reply.
    var replayKey = route.write && req.requestId
      ? who + ':' + req.action + ':' + String(req.requestId).slice(0, 64) : null;
    if (replayKey) {
      var replay = Guard.replay(replayKey);
      if (replay) return replay;
    }

    Guard.rateLimit(req.action + ':' + who, route.rate[0], route.rate[1]);
    if (route.auth) {
      ctx.user = Auth.userRecord(ctx.principal);
      if (route.roles) Auth.requireRole(ctx.user, route.roles);
    }
    var response = { ok: true, data: route.handler(ctx) || {} };
    if (replayKey) Guard.remember(replayKey, response);
    return response;
  } catch (err) {
    if (err instanceof ApiError) return fail_(err.code, err.message);
    console.error(err && err.stack ? err.stack : err);
    // Never leak internals to the client.
    return fail_('server_error', 'Something went wrong');
  }
}

function fail_(code, message) {
  return { ok: false, error: { code: code, message: message } };
}

function json_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function audit_(actorUid, action, target, detail) {
  Db.append('AdminAuditLog', [new Date().toISOString(), actorUid, action, target || '', detail || '']);
}
