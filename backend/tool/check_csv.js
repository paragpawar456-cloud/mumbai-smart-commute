#!/usr/bin/env node
// Checks timetable CSVs before you paste them into the Sheet, using the exact
// validator the server runs on "Publish data pack".
//   node backend/tool/check_csv.js [folder]   (default: data/templates)
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const { loadCsvTables } = require('./csv');

const dir = path.resolve(process.argv[2] || path.join(__dirname, '..', '..', 'data', 'templates'));
const ctx = vm.createContext({ console });
vm.runInContext(fs.readFileSync(path.join(__dirname, '..', 'apps-script', 'Pack.gs'), 'utf8'), ctx);
ctx.__t = loadCsvTables(dir);
const errors = vm.runInContext("validatePack_(tablesToPack_(__t, 1, new Date().toISOString()))", ctx);
const counts = Object.entries(ctx.__t).map(([k, v]) => `${k}: ${v.length}`).join(', ');
console.log(`Checked ${dir}\n${counts}`);
if (errors.length) {
  console.error(`\n${errors.length} problem(s):\n- ` + Array.from(errors).join('\n- '));
  process.exit(1);
}
console.log('No problems found.');
