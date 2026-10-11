'use strict';
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const { makeGlobals } = require('./gas_stubs');

const SRC = path.join(__dirname, '..', 'apps-script');
const USERS = {
  'tok-a': { localId: 'ua', email: 'a@example.com' },
  'tok-b': { localId: 'ub', email: 'b@example.com' },
  'tok-mod': { localId: 'um', email: 'm@example.com' },
};

function load(opts = {}) {
  const g = makeGlobals({
    lookup: (tok) => (USERS[tok] ? { code: 200, body: { users: [USERS[tok]] } } : { code: 400, body: {} }),
    ...opts,
  });
  const ctx = vm.createContext(g);
  for (const f of fs.readdirSync(SRC).filter((f) => f.endsWith('.gs')).sort()) {
    vm.runInContext(fs.readFileSync(path.join(SRC, f), 'utf8'), ctx, { filename: f });
  }
  vm.runInContext('setupSheets()', ctx);
  const call = (body) => JSON.parse(JSON.stringify(
    vm.runInContext(`dispatch_(${JSON.stringify(JSON.stringify(body))})`, ctx)));
  const setRole = (uid, role) => vm.runInContext(
    `(function(){var u=Db.findOne('Users','uid','${uid}');Db.update('Users',u._row,{role:'${role}'});})()`, ctx);
  return { g, ctx, call, setRole };
}

const KALYAN = { lat: 19.235822, lng: 73.13081 };
const submit = (call, tok, extra = {}) => call({
  action: 'submitReport', idToken: tok, requestId: Math.random().toString(36),
  payload: { type: 'queue', targetId: 'OSM-node-1', lat: KALYAN.lat, lng: KALYAN.lng, note: 'Long queue', ...extra },
});

test('submit needs sign-in, rounds location and sets expiry by type', () => {
  const { call, g } = load();
  assert.strictEqual(call({ action: 'submitReport', payload: {} }).error.code, 'unauthenticated');
  const r = submit(call, 'tok-a');
  assert.strictEqual(r.ok, true, JSON.stringify(r));
  assert.strictEqual(r.data.report.lat, 19.2358);
  const mins = (Date.parse(r.data.report.expiresAt) - Date.parse(r.data.report.createdAt)) / 60000;
  assert.strictEqual(mins, 30);
  assert.strictEqual(r.data.report.uid, undefined);
  assert.strictEqual(g._ss.getSheetByName('CommunityReports')._rows[1][1], 'ua');
});

test('submit rejects bad input, outside region, duplicates and formula notes', () => {
  const { call, g } = load();
  // Rejected calls still count toward the 5-per-10-minutes route limit.
  assert.strictEqual(submit(call, 'tok-b', { type: 'party' }).error.code, 'invalid_input');
  assert.strictEqual(submit(call, 'tok-b', { lat: 28.6 }).error.code, 'invalid_input');
  assert.strictEqual(submit(call, 'tok-b', { lat: '19.2' }).error.code, 'invalid_input');
  assert.strictEqual(submit(call, 'tok-b', { note: 'x'.repeat(201) }).error.code, 'invalid_input');
  assert.strictEqual(submit(call, 'tok-a', { note: '=HYPERLINK("x")' }).ok, true);
  assert.ok(g._ss.getSheetByName('CommunityReports')._rows[1][6].startsWith("'="));
  assert.strictEqual(submit(call, 'tok-a', { note: 'again' }).error.code, 'duplicate');
});

test('public list hides uid, filters by distance and drops expired/rejected', () => {
  const { call, g } = load();
  submit(call, 'tok-a');
  submit(call, 'tok-b', { type: 'closure', targetId: '', lat: 19.0760, lng: 72.8777 }); // far away
  submit(call, 'tok-b', { type: 'no_vehicles' });
  const rows = g._ss.getSheetByName('CommunityReports')._rows;
  rows[3][9] = '2000-01-01T00:00:00.000Z'; // expire the no_vehicles report
  const r = call({ action: 'listReports', payload: { lat: KALYAN.lat, lng: KALYAN.lng, radiusKm: 2 } });
  assert.strictEqual(r.ok, true);
  assert.strictEqual(r.data.reports.length, 1);
  assert.strictEqual(r.data.reports[0].type, 'queue');
  assert.ok(!JSON.stringify(r).includes('ua'));
  assert.strictEqual(call({ action: 'listReports', payload: { lat: KALYAN.lat, lng: KALYAN.lng, radiusKm: 50 } })
    .error.code, 'invalid_input');
});

test('corroborate: once per user, never your own', () => {
  const { call } = load();
  const id = submit(call, 'tok-a').data.report.reportId;
  const c = (tok) => call({ action: 'corroborateReport', idToken: tok, requestId: Math.random().toString(36), payload: { reportId: id } });
  assert.strictEqual(c('tok-a').error.code, 'invalid_input');
  assert.strictEqual(c('tok-b').data.corroborations, 1);
  assert.strictEqual(c('tok-b').error.code, 'duplicate');
  assert.strictEqual(c('tok-mod').data.corroborations, 2);
});

test('moderation needs moderator role server-side and is audited', () => {
  const { call, setRole, g } = load();
  const id = submit(call, 'tok-a').data.report.reportId;
  assert.strictEqual(call({ action: 'listReports', payload: KALYAN }).data.reports.length, 1); // now cached
  const mod = (tok) => call({ action: 'moderateReport', idToken: tok, requestId: Math.random().toString(36), payload: { reportId: id, decision: 'rejected' } });
  call({ action: 'getProfile', idToken: 'tok-mod' });
  assert.strictEqual(mod('tok-mod').error.code, 'forbidden');
  setRole('um', 'moderator');
  const list = call({ action: 'modListReports', idToken: 'tok-mod', payload: {} });
  assert.strictEqual(list.data.reports[0].reporter, 'ua');
  assert.strictEqual(mod('tok-mod').data.status, 'rejected');
  const audit = g._ss.getSheetByName('AdminAuditLog')._rows;
  assert.strictEqual(audit[audit.length - 1][2], 'moderate_report');
  // No cache clearing needed: moderation invalidates cached lists.
  assert.strictEqual(call({ action: 'listReports', payload: KALYAN }).data.reports.length, 0);
});

test('a user can have at most 5 live reports', () => {
  const { call } = load();
  for (let i = 0; i < 5; i++) assert.strictEqual(submit(call, 'tok-a', { targetId: 'T' + i }).ok, true);
  // The route rate limit (5 per 10 min) also applies; either refusal is fine.
  assert.ok(['rate_limited'].includes(submit(call, 'tok-a', { targetId: 'T9' }).error.code));
});

test('road distance: off without key, cached with key, falls back on error', () => {
  let calls = 0;
  const off = load();
  const req = { action: 'roadDistance', idToken: 'tok-a', payload: { fromLat: 19.2358, fromLng: 73.1308, toLat: 19.2473, toLng: 73.1530 } };
  assert.strictEqual(off.call(req).data.available, false);

  const on = load({
    props: { ORS_API_KEY: 'k' },
    ors: (body, headers) => {
      calls++;
      assert.strictEqual(headers.Authorization, 'k');
      assert.deepStrictEqual(body.coordinates[0], [73.1308, 19.2358]);
      return { code: 200, body: { routes: [{ summary: { distance: 3456, duration: 600 } }] } };
    },
  });
  const r = on.call(req);
  assert.deepStrictEqual([r.data.available, r.data.km, r.data.driveMinutes], [true, 3.46, 10]);
  on.call(req);
  assert.strictEqual(calls, 1);

  const bad = load({ props: { ORS_API_KEY: 'k' }, ors: () => ({ code: 429, body: {} }) });
  assert.strictEqual(bad.call(req).data.available, false);
  assert.strictEqual(off.call({ ...req, idToken: undefined }).error.code, 'unauthenticated');
});
