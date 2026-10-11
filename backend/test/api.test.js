'use strict';
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const { makeGlobals } = require('./gas_stubs');

const SRC = path.join(__dirname, '..', 'apps-script');
const USERS = {
  'tok-user': { localId: 'u1', email: 'a@example.com', emailVerified: true },
  'tok-admin': { localId: 'admin1', email: 'admin@example.com', emailVerified: true },
  'tok-other': { localId: 'u2', email: 'b@example.com', emailVerified: true },
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
  const call = (body) => vm.runInContext(`dispatch_(${JSON.stringify(JSON.stringify(body))})`, ctx);
  const makeAdmin = (uid) => vm.runInContext(
    `(function(){var u=Db.findOne('Users','uid','${uid}');Db.update('Users',u._row,{role:'admin'});})()`, ctx);
  return { g, ctx, call, makeAdmin };
}

test('setupSheets creates every tab with headers and is re-runnable', () => {
  const { g, ctx } = load();
  const names = vm.runInContext('Object.keys(SCHEMA)', ctx);
  for (const n of names) assert.ok(g._ss.getSheetByName(n), n);
  assert.deepStrictEqual(g._ss.getSheetByName('Users')._rows[0].slice(0, 2), ['uid', 'email']);
  vm.runInContext('setupSheets()', ctx);
  assert.strictEqual(g._ss.getSheetByName('AppConfiguration')._rows.length, 6); // header + 5 seeds
});

test('health is public and reports data pack version', () => {
  const { call } = load();
  const r = call({ action: 'health' });
  assert.strictEqual(r.ok, true);
  assert.strictEqual(r.data.dataPackVersion, '0');
});

test('unknown action and bad JSON give structured errors', () => {
  const { call, ctx } = load();
  assert.strictEqual(call({ action: 'nope' }).error.code, 'not_found');
  assert.strictEqual(vm.runInContext('dispatch_("{bad")', ctx).error.code, 'invalid_input');
});

test('private actions reject missing or invalid tokens', () => {
  const { call } = load();
  assert.strictEqual(call({ action: 'getProfile' }).error.code, 'unauthenticated');
  assert.strictEqual(call({ action: 'getProfile', idToken: 'forged' }).error.code, 'unauthenticated');
});

test('first authenticated call creates a user row with role "user"', () => {
  const { call, g } = load();
  const r = call({ action: 'getProfile', idToken: 'tok-user' });
  assert.strictEqual(r.ok, true);
  assert.strictEqual(r.data.profile.role, 'user');
  assert.strictEqual(r.data.profile.email, 'a@example.com');
  assert.strictEqual(g._ss.getSheetByName('Users')._rows.length, 2);
});

test('token lookups are cached (quota protection)', () => {
  const { call, g } = load();
  call({ action: 'getProfile', idToken: 'tok-user' });
  call({ action: 'getProfile', idToken: 'tok-user' });
  assert.strictEqual(g._fetches.length, 1);
});

test('client cannot grant itself admin via payload', () => {
  const { call } = load();
  call({ action: 'updateProfile', idToken: 'tok-user', payload: { role: 'admin', displayName: 'A' } });
  const r = call({ action: 'adminListUsers', idToken: 'tok-user' });
  assert.strictEqual(r.error.code, 'forbidden');
});

test('updateProfile validates and neutralises formula injection', () => {
  const { call } = load();
  const bad = call({ action: 'updateProfile', idToken: 'tok-user', payload: { preferredLanguage: 'fr' } });
  assert.strictEqual(bad.error.code, 'invalid_input');
  const ok = call({ action: 'updateProfile', idToken: 'tok-user', requestId: 'r1',
                    payload: { displayName: '=HYPERLINK("x")', preferredLanguage: 'mr' } });
  assert.strictEqual(ok.data.profile.displayName, '\'=HYPERLINK("x")');
  assert.strictEqual(ok.data.profile.preferredLanguage, 'mr');
});

test('duplicate requestId replays instead of writing twice', () => {
  const { call, g } = load();
  call({ action: 'getProfile', idToken: 'tok-user' });
  const a = call({ action: 'deleteMyData', idToken: 'tok-user', requestId: 'dup1' });
  const b = call({ action: 'deleteMyData', idToken: 'tok-user', requestId: 'dup1' });
  assert.strictEqual(JSON.stringify(a), JSON.stringify(b));
  const audits = g._ss.getSheetByName('AdminAuditLog')._rows.length - 1;
  assert.strictEqual(audits, 1);
});

test('rate limit kicks in', () => {
  const { call } = load();
  let last;
  for (let i = 0; i < 11; i++) {
    last = call({ action: 'updateProfile', idToken: 'tok-user', payload: { displayName: 'n' + i } });
  }
  assert.strictEqual(last.error.code, 'rate_limited');
});

test('deleteMyData wipes personal fields and blocks further use', () => {
  const { call, g } = load();
  call({ action: 'updateProfile', idToken: 'tok-user', payload: { displayName: 'Asha' } });
  assert.strictEqual(call({ action: 'deleteMyData', idToken: 'tok-user' }).ok, true);
  const row = g._ss.getSheetByName('Users')._rows[1];
  assert.strictEqual(row[1], ''); // email
  assert.strictEqual(row[2], ''); // display_name
  assert.strictEqual(call({ action: 'getProfile', idToken: 'tok-user' }).error.code, 'forbidden');
});

test('admin can list and disable users; action is audited; disabled user is blocked', () => {
  const { call, makeAdmin, g } = load();
  call({ action: 'getProfile', idToken: 'tok-admin' });
  call({ action: 'getProfile', idToken: 'tok-other' });
  makeAdmin('admin1');
  const list = call({ action: 'adminListUsers', idToken: 'tok-admin', payload: { query: 'b@' } });
  assert.strictEqual(list.data.total, 1);
  const dis = call({ action: 'adminSetUserStatus', idToken: 'tok-admin', payload: { uid: 'u2', status: 'disabled' } });
  assert.strictEqual(dis.ok, true);
  assert.strictEqual(call({ action: 'getProfile', idToken: 'tok-other' }).error.code, 'forbidden');
  const log = g._ss.getSheetByName('AdminAuditLog')._rows.map((r) => r[2]);
  assert.ok(log.includes('set_user_status'));
});

test('internal errors are not leaked', () => {
  const { call, g } = load();
  g._ss.deleteSheet(g._ss.getSheetByName('AppConfiguration'));
  const r = call({ action: 'getConfig' });
  assert.strictEqual(r.ok, false);
  assert.ok(!/stack|TypeError/.test(r.error.message));
});

test('a requestId reused by another user does not replay their response', () => {
  const { call } = load();
  call({ action: 'updateProfile', idToken: 'tok-user', requestId: 'same', payload: { displayName: 'Asha' } });
  const other = call({ action: 'updateProfile', idToken: 'tok-other', requestId: 'same', payload: { displayName: 'Ravi' } });
  assert.strictEqual(other.data.profile.displayName, 'Ravi');
  assert.strictEqual(other.data.profile.email, 'b@example.com');
});
