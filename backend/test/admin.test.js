'use strict';
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const { makeGlobals } = require('./gas_stubs');

const SRC = path.join(__dirname, '..', 'apps-script');
const USERS = {
  'tok-admin': { localId: 'admin1', email: 'admin@example.com' },
  'tok-mod': { localId: 'mod1', email: 'mod@example.com' },
  'tok-user': { localId: 'u1', email: 'u@example.com' },
};

function load() {
  const g = makeGlobals({
    lookup: (tok) => (USERS[tok] ? { code: 200, body: { users: [USERS[tok]] } } : { code: 400, body: {} }),
  });
  const ctx = vm.createContext(g);
  for (const f of fs.readdirSync(SRC).filter((f) => f.endsWith('.gs')).sort()) {
    vm.runInContext(fs.readFileSync(path.join(SRC, f), 'utf8'), ctx, { filename: f });
  }
  vm.runInContext('setupSheets()', ctx);
  let n = 0;
  const call = (body) => JSON.parse(JSON.stringify(vm.runInContext(
    `dispatch_(${JSON.stringify(JSON.stringify({ requestId: 'r' + n++, ...body }))})`, ctx)));
  for (const tok of Object.keys(USERS)) call({ action: 'getProfile', idToken: tok });
  const setRole = (uid, role) => vm.runInContext(
    `(function(){var u=Db.findOne('Users','uid','${uid}');Db.update('Users',u._row,{role:'${role}'});})()`, ctx);
  setRole('admin1', 'admin');
  setRole('mod1', 'moderator');
  return { g, ctx, call };
}

const ADMIN_ONLY = ['adminOverview', 'adminListAudit', 'adminListAlerts', 'adminSaveAlert',
  'adminEndAlert', 'adminSetUserRole', 'adminSetUserStatus', 'adminListUsers'];

test('every admin action is rejected for users and moderators, on the server', () => {
  const { call } = load();
  for (const action of ADMIN_ONLY) {
    for (const tok of ['tok-user', 'tok-mod']) {
      assert.strictEqual(call({ action, idToken: tok, payload: {} }).error.code, 'forbidden', `${action} ${tok}`);
    }
    assert.strictEqual(call({ action, payload: {} }).error.code, 'unauthenticated', action);
  }
  // Moderators can moderate reports but nothing else.
  assert.strictEqual(call({ action: 'modListReports', idToken: 'tok-mod', payload: {} }).ok, true);
  assert.strictEqual(call({ action: 'modListReports', idToken: 'tok-user', payload: {} }).error.code, 'forbidden');
});

test('admin changes roles (not their own) and it is audited', () => {
  const { call, g } = load();
  assert.strictEqual(call({ action: 'adminSetUserRole', idToken: 'tok-admin', payload: { uid: 'admin1', role: 'user' } })
    .error.code, 'invalid_input');
  assert.strictEqual(call({ action: 'adminSetUserRole', idToken: 'tok-admin', payload: { uid: 'u1', role: 'root' } })
    .error.code, 'invalid_input');
  assert.strictEqual(call({ action: 'adminSetUserRole', idToken: 'tok-admin', payload: { uid: 'u1', role: 'moderator' } })
    .data.role, 'moderator');
  assert.strictEqual(call({ action: 'modListReports', idToken: 'tok-user', payload: {} }).ok, true);
  const last = g._ss.getSheetByName('AdminAuditLog')._rows.slice(-1)[0];
  assert.deepStrictEqual([last[1], last[2], last[3], last[4]], ['admin1', 'set_user_role', 'u1', 'moderator']);
});

test('overview counts users, reports, alerts and shows data health', () => {
  const { call } = load();
  call({ action: 'submitReport', idToken: 'tok-user', payload: { type: 'queue', lat: 19.2358, lng: 73.1308 } });
  const o = call({ action: 'adminOverview', idToken: 'tok-admin' }).data;
  assert.deepStrictEqual(
    [o.users.total, o.users.active, o.users.admins, o.users.moderators, o.reports.pending, o.dataPack.version],
    [3, 3, 1, 1, 1, 0]);
  assert.strictEqual(o.roadDistanceEnabled, false);
  assert.ok(Array.isArray(o.sync));
});

test('audit log is newest first and paged', () => {
  const { call } = load();
  call({ action: 'adminSetUserRole', idToken: 'tok-admin', payload: { uid: 'u1', role: 'moderator' } });
  call({ action: 'adminSetUserRole', idToken: 'tok-admin', payload: { uid: 'u1', role: 'user' } });
  const a = call({ action: 'adminListAudit', idToken: 'tok-admin', payload: { pageSize: 1 } }).data;
  assert.strictEqual(a.total, 2);
  assert.strictEqual(a.entries.length, 1);
  assert.strictEqual(a.entries[0].detail, 'user');
});

test('alerts: admin creates with an official https source, public sees active ones, ending hides it', () => {
  const { call } = load();
  const base = { scope: 'CR-MAIN', severity: 'major', titleEn: 'Megablock Thane–Kalyan',
    startsAt: '2026-10-01T00:00:00Z', sourceUrl: 'https://cr.indianrailways.gov.in/' };
  assert.strictEqual(call({ action: 'adminSaveAlert', idToken: 'tok-admin', payload: { ...base, sourceUrl: '' } })
    .error.code, 'invalid_input');
  assert.strictEqual(call({ action: 'adminSaveAlert', idToken: 'tok-admin', payload: { ...base, sourceUrl: 'http://x' } })
    .error.code, 'invalid_input');
  assert.strictEqual(call({ action: 'adminSaveAlert', idToken: 'tok-admin',
    payload: { ...base, endsAt: '2026-09-01T00:00:00Z' } }).error.code, 'invalid_input');
  const future = call({ action: 'adminSaveAlert', idToken: 'tok-admin', payload: { ...base, startsAt: '2099-01-01T00:00:00Z' } });
  assert.strictEqual(future.ok, true);
  const made = call({ action: 'adminSaveAlert', idToken: 'tok-admin', payload: base }).data.alert;

  let pub = call({ action: 'getAlerts' }).data.alerts;
  assert.deepStrictEqual(pub.map((a) => a.alertId), [made.alertId]); // future one not yet in force
  assert.strictEqual(pub[0].sourceUrl, base.sourceUrl);
  assert.strictEqual(pub[0].created_by, undefined);

  call({ action: 'adminSaveAlert', idToken: 'tok-admin', payload: { ...base, alertId: made.alertId, titleEn: 'Updated' } });
  assert.strictEqual(call({ action: 'getAlerts' }).data.alerts[0].titleEn, 'Updated'); // cache invalidated
  call({ action: 'adminEndAlert', idToken: 'tok-admin', payload: { alertId: made.alertId } });
  assert.strictEqual(call({ action: 'getAlerts' }).data.alerts.length, 0);
  assert.strictEqual(call({ action: 'adminListAlerts', idToken: 'tok-admin' }).data.alerts.length, 2);
});
