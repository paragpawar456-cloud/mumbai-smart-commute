function handleHealth() {
  var v = Db.findOne('AppConfiguration', 'key', 'data_pack_version');
  return { status: 'up', time: new Date().toISOString(), dataPackVersion: v ? String(v.value) : null };
}

function handleGetConfig() {
  var out = {};
  Db.all('AppConfiguration').forEach(function (r) {
    if (r.public === true || r.public === 'TRUE') out[r.key] = String(r.value);
  });
  return { config: out };
}

function publicProfile_(u) {
  return {
    uid: u.uid, email: u.email, displayName: u.display_name,
    preferredLanguage: u.preferred_language, role: u.role,
    consentVersion: u.consent_version, createdAt: u.created_at,
  };
}

function handleGetProfile(ctx) {
  var today = new Date().toISOString().slice(0, 10);
  if (String(ctx.user.last_seen_at).slice(0, 10) !== today) {
    Db.withLock(function () { Db.update('Users', ctx.user._row, { last_seen_at: today }); });
  }
  return { profile: publicProfile_(ctx.user) };
}

function handleUpdateProfile(ctx) {
  var p = ctx.payload;
  var patch = { updated_at: new Date().toISOString() };
  if (p.displayName !== undefined) patch.display_name = Validate.string(p.displayName, 'displayName', { max: 60 });
  if (p.preferredLanguage !== undefined) patch.preferred_language = Validate.oneOf(p.preferredLanguage, 'preferredLanguage', ['en', 'mr', 'hi']);
  if (p.consentVersion !== undefined) patch.consent_version = Validate.string(p.consentVersion, 'consentVersion', { max: 20 });
  Db.withLock(function () { Db.update('Users', ctx.user._row, patch); });
  return { profile: publicProfile_(Db.findOne('Users', 'uid', ctx.user.uid)) };
}

/**
 * Removes the user's personal data. Community reports are kept for other
 * commuters but de-linked from the account. The Firebase account itself is
 * deleted by the app right after this call succeeds.
 */
function handleDeleteMyData(ctx) {
  var uid = ctx.user.uid;
  return Db.withLock(function () {
    var removed = Db.deleteWhere('SavedRoutes', 'uid', uid);
    Db.all('CommunityReports').forEach(function (r) {
      if (r.uid === uid) Db.update('CommunityReports', r._row, { uid: 'deleted' });
    });
    Db.update('Users', ctx.user._row, {
      email: '', display_name: '', status: 'deleted', updated_at: new Date().toISOString(),
    });
    audit_(uid, 'self_delete', uid, 'saved_routes=' + removed);
    return { deleted: true };
  });
}

function handleAdminListUsers(ctx) {
  var p = ctx.payload;
  var q = Validate.string(p.query, 'query', { max: 80 }).toLowerCase();
  var status = p.status ? Validate.oneOf(p.status, 'status', ['active', 'disabled', 'deleted']) : null;
  var pageSize = p.pageSize ? Validate.int(p.pageSize, 'pageSize', 1, 100) : 25;
  var page = p.page ? Validate.int(p.page, 'page', 0, 10000) : 0;
  var rows = Db.all('Users').filter(function (u) {
    if (status && u.status !== status) return false;
    if (!q) return true;
    return String(u.email).toLowerCase().indexOf(q) !== -1 ||
           String(u.display_name).toLowerCase().indexOf(q) !== -1;
  });
  rows.sort(function (a, b) { return String(b.created_at).localeCompare(String(a.created_at)); });
  audit_(ctx.user.uid, 'list_users', '', 'q=' + (q ? 'yes' : 'no'));
  return {
    total: rows.length, page: page, pageSize: pageSize,
    users: rows.slice(page * pageSize, (page + 1) * pageSize).map(function (u) {
      return { uid: u.uid, email: u.email, displayName: u.display_name, role: u.role,
               status: u.status, createdAt: u.created_at, lastSeenAt: u.last_seen_at };
    }),
  };
}

function handleAdminSetUserStatus(ctx) {
  var p = ctx.payload;
  var uid = Validate.string(p.uid, 'uid', { required: true, max: 128 });
  var status = Validate.oneOf(p.status, 'status', ['active', 'disabled']);
  if (uid === ctx.user.uid) throw new ApiError('invalid_input', 'Cannot change your own status');
  return Db.withLock(function () {
    var target = Db.findOne('Users', 'uid', uid);
    if (!target) throw new ApiError('not_found', 'User not found');
    if (target.status === 'deleted') throw new ApiError('invalid_input', 'User deleted');
    Db.update('Users', target._row, { status: status, updated_at: new Date().toISOString() });
    audit_(ctx.user.uid, 'set_user_status', uid, status);
    return { uid: uid, status: status };
  });
}
