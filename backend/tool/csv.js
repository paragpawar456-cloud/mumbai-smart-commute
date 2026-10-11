// Tiny RFC 4180 CSV reader (quotes, commas, newlines in quotes). No deps.
'use strict';
const fs = require('fs');
const path = require('path');

function parseCsv(text) {
  const rows = [];
  let row = [], field = '', i = 0, quoted = false;
  text = text.replace(/^﻿/, '');
  while (i < text.length) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') { field += '"'; i += 2; continue; }
      if (c === '"') { quoted = false; i++; continue; }
      field += c; i++; continue;
    }
    if (c === '"') { quoted = true; i++; continue; }
    if (c === ',') { row.push(field); field = ''; i++; continue; }
    if (c === '\r') { i++; continue; }
    if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; i++; continue; }
    field += c; i++;
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row); }
  const [header, ...body] = rows.filter((r) => r.some((x) => x !== ''));
  return body.map((r) => Object.fromEntries((header || []).map((h, j) => [h, r[j] ?? ''])));
}

const TABLES = ['Stations', 'TrainRoutes', 'Interchanges', 'TrainTrips', 'TripStopTimes', 'DataSources',
  'Places', 'PickupPoints', 'BusStops', 'BusRoutes', 'FareRules', 'TransportProviders'];

function loadCsvTables(dir) {
  const out = {};
  for (const t of TABLES) {
    const f = path.join(dir, `${t}.csv`);
    out[t] = fs.existsSync(f) ? parseCsv(fs.readFileSync(f, 'utf8')) : [];
  }
  return out;
}

module.exports = { parseCsv, loadCsvTables };
