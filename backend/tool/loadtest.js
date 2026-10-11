#!/usr/bin/env node
// Load test for the deployed Apps Script web app. Run it after deploying
// (docs/SETUP.md) to measure real latency and find quota errors before
// telling anyone how many users the pilot can take.
//
//   node backend/tool/loadtest.js <exec-url> [--users 30] [--seconds 60] [--token <Firebase ID token>]
//
// Each virtual user repeats what the app does when opened: getDataPack with
// the current version (normally "unchanged"), getAlerts, and listReports near
// Kalyan, with a 1–3 s pause between calls. --token adds getProfile calls as
// a signed-in user. Only read actions are sent; nothing is written.
'use strict';

const args = process.argv.slice(2);
const url = args.find((a) => /^https?:\/\//.test(a));
const opt = (name, def) => {
  const i = args.indexOf('--' + name);
  return i === -1 ? def : args[i + 1];
};
if (!url) {
  console.error('Usage: node backend/tool/loadtest.js <exec-url> [--users 30] [--seconds 60] [--token T]');
  process.exit(2);
}
const users = Number(opt('users', 30));
const seconds = Number(opt('seconds', 60));
const token = opt('token', null);
const results = []; // {action, ms, code}

async function call(action, payload = {}, idToken) {
  const started = Date.now();
  let code;
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'text/plain;charset=utf-8' },
      body: JSON.stringify({ action, payload, idToken, requestId: Math.random().toString(36).slice(2) }),
      redirect: 'follow',
    });
    const text = await res.text();
    try {
      const body = JSON.parse(text);
      code = body.ok ? 'ok' : body.error.code;
      return body;
    } catch {
      code = 'http_' + res.status + '_not_json';
    }
  } catch (e) {
    code = 'network';
  } finally {
    results.push({ action, ms: Date.now() - started, code });
  }
  return null;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function virtualUser(deadline, version) {
  while (Date.now() < deadline) {
    await call('getDataPack', { haveVersion: version });
    await sleep(1000 + Math.random() * 2000);
    await call('getAlerts');
    await sleep(1000 + Math.random() * 2000);
    await call('listReports', { lat: 19.2358, lng: 73.1308, radiusKm: 2 });
    if (token) await call('getProfile', {}, token);
    await sleep(1000 + Math.random() * 2000);
  }
}

function pct(sorted, p) {
  return sorted.length ? sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * p))] : 0;
}

(async () => {
  const health = await call('health');
  if (!health || !health.ok) {
    console.error('Health check failed; is the URL a deployed /exec URL with access "Anyone"?');
    process.exit(1);
  }
  const version = Number(health.data.dataPackVersion || 0);
  console.log(`Data pack v${version}. ${users} users for ${seconds}s…`);
  const deadline = Date.now() + seconds * 1000;
  // Ramp up over 10 s instead of a thundering herd.
  await Promise.all(Array.from({ length: users }, (_, i) =>
    sleep((i * 10000) / users).then(() => virtualUser(deadline, version))));

  const byAction = {};
  for (const r of results) (byAction[r.action] = byAction[r.action] || []).push(r);
  console.log('\naction        calls   p50 ms   p95 ms   max ms   errors');
  for (const [action, rs] of Object.entries(byAction)) {
    const ms = rs.map((r) => r.ms).sort((a, b) => a - b);
    const errs = rs.filter((r) => r.code !== 'ok');
    console.log(`${action.padEnd(12)} ${String(rs.length).padStart(6)} ${String(pct(ms, 0.5)).padStart(8)} ` +
      `${String(pct(ms, 0.95)).padStart(8)} ${String(ms[ms.length - 1]).padStart(8)}   ${errs.length}`);
  }
  const codes = {};
  for (const r of results) if (r.code !== 'ok') codes[r.code] = (codes[r.code] || 0) + 1;
  console.log('\nerror codes:', Object.keys(codes).length ? codes : 'none');
  console.log(`throughput: ${(results.length / seconds).toFixed(2)} calls/s`);
  console.log('\nNote: anonymous rate limits are 600/min per action for everyone together (D16);');
  console.log('"rate_limited" above that is the server protecting its quota, not a crash.');
})();
