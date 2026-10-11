'use strict';
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const { makeGlobals } = require('./gas_stubs');
const { loadCsvTables } = require('../tool/csv');

const SRC = path.join(__dirname, '..', 'apps-script');
const TEMPLATES = path.join(__dirname, '..', '..', 'data', 'templates');

function load() {
  const g = makeGlobals({ lookup: () => ({ code: 400, body: {} }) });
  const ctx = vm.createContext(g);
  for (const f of fs.readdirSync(SRC).filter((f) => f.endsWith('.gs')).sort()) {
    vm.runInContext(fs.readFileSync(path.join(SRC, f), 'utf8'), ctx, { filename: f });
  }
  vm.runInContext('setupSheets()', ctx);
  return { g, ctx, call: (b) => vm.runInContext(`dispatch_(${JSON.stringify(JSON.stringify(b))})`, ctx) };
}

function fill(g, ctx, tables) {
  for (const [name, rows] of Object.entries(tables)) {
    const headers = vm.runInContext(`SCHEMA[${JSON.stringify(name)}].columns.map(function(c){return c[0];})`, ctx);
    const sheet = g._ss.getSheetByName(name);
    for (const r of rows) sheet.appendRow(headers.map((h) => (r[h] === undefined ? '' : r[h])));
  }
}

function setConfig(g, key, value) {
  const rows = g._ss.getSheetByName('AppConfiguration')._rows;
  rows.find((r) => r[0] === key)[1] = value;
}

const tripRow = (id, days = 'MON-SAT') => ({
  trip_id: id, route_id: 'CR-MAIN', train_number: '', direction: 'up', service_days: days,
  train_type: 'slow', ac: 'FALSE', ladies_special: 'FALSE', valid_from: '2026-10-01', source_id: 'test',
});

test('seed templates pass validation (stations, lines, interchanges)', () => {
  const { ctx } = load();
  const tables = loadCsvTables(TEMPLATES);
  ctx.__t = tables;
  const errors = vm.runInContext("validatePack_(tablesToPack_(__t, 1, 'x'))", ctx);
  assert.deepStrictEqual(Array.from(errors), []);
});

test('validator catches the mistakes people make entering timetables', () => {
  const { ctx } = load();
  const t = loadCsvTables(TEMPLATES);
  t.TrainTrips = [tripRow('T1'), { ...tripRow('T2'), service_days: 'WEEKDAYS', source_id: '' }];
  t.TripStopTimes = [
    { trip_id: 'T1', seq: 1, station_id: 'KYN', arrival: '', departure: '08:00' },
    { trip_id: 'T1', seq: 2, station_id: 'THK', arrival: '07:58', departure: '08:03' }, // back in time
    { trip_id: 'T1', seq: 3, station_id: 'KYN', arrival: '', departure: '08:10' },      // direction flip
    { trip_id: 'T1', seq: 4, station_id: 'M1-AND', arrival: '', departure: '8.15' },    // not on line, bad time
    { trip_id: 'T9', seq: 1, station_id: 'KYN', arrival: '', departure: '09:00' },      // unknown trip
  ];
  ctx.__t = t;
  const errors = Array.from(vm.runInContext("validatePack_(tablesToPack_(__t, 1, 'x'))", ctx)).join('\n');
  for (const needle of ['goes back in time', 'changes direction', 'not on route CR-MAIN', 'bad departure',
                        'unknown trip T9', 'invalid service_days', 'no source_id', 'T2 has fewer than 2 stops']) {
    assert.ok(errors.includes(needle), `missing: ${needle}\n${errors}`);
  }
});

test('getDataPack: unchanged before publish, full pack after, unchanged when up to date', () => {
  const { g, ctx, call } = load();
  fill(g, ctx, loadCsvTables(TEMPLATES));
  assert.strictEqual(call({ action: 'getDataPack', payload: { haveVersion: 1 } }).data.unchanged, true);

  setConfig(g, 'data_pack_version', '2');
  setConfig(g, 'data_pack_generated_at', '2026-10-11T07:00:00Z');
  const r = call({ action: 'getDataPack', payload: { haveVersion: 1 } });
  assert.strictEqual(r.ok, true);
  assert.strictEqual(r.data.pack.version, 2);
  assert.strictEqual(r.data.pack.stations.length, 38);
  assert.strictEqual(r.data.pack.lines.length, 2);
  assert.strictEqual(typeof r.data.pack.stations[0].lat, 'number');

  assert.strictEqual(call({ action: 'getDataPack', payload: { haveVersion: 2 } }).data.unchanged, true);
});

test('large packs are cached in chunks under the 100 KB cache limit', () => {
  const { g, ctx, call } = load();
  const t = loadCsvTables(TEMPLATES);
  const seq = t.TrainRoutes.find((r) => r.route_id === 'CR-MAIN').station_sequence.split(',');
  t.TrainTrips = [];
  t.TripStopTimes = [];
  for (let i = 0; i < 300; i++) {
    t.TrainTrips.push(tripRow('T' + i));
    seq.forEach((st, k) => {
      const m = 300 + i * 4 + k * 3;
      const hhmm = `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;
      t.TripStopTimes.push({ trip_id: 'T' + i, seq: k + 1, station_id: st, arrival: hhmm, departure: hhmm });
    });
  }
  fill(g, ctx, t);
  setConfig(g, 'data_pack_version', '3');
  const first = call({ action: 'getDataPack', payload: { haveVersion: 0 } });
  assert.strictEqual(first.data.pack.stop_times.length, 300 * seq.length);
  const chunks = [...g._cache._m.keys()].filter((k) => k.startsWith('pack:3:') && k !== 'pack:3:n');
  assert.ok(chunks.length > 1, 'expected several chunks');
  for (const k of chunks) assert.ok(g._cache._m.get(k).length <= 90000);
  const again = call({ action: 'getDataPack', payload: { haveVersion: 0 } });
  assert.strictEqual(JSON.stringify(again), JSON.stringify(first));
});
