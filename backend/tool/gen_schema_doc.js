// Prints docs/SHEET_SCHEMA.md from apps-script/Schema.gs so the doc never drifts.
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const ctx = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(__dirname, '..', 'apps-script', 'Schema.gs'), 'utf8'), ctx);
const S = vm.runInContext('SCHEMA', ctx);
const out = ['# Google Sheet schema', '',
  'Generated from `backend/apps-script/Schema.gs` by `npm run schema-doc` (in `backend/`). Do not edit by hand.', '',
  'The Sheet is private to the owner. The app never reads it directly; every read and write goes through the Apps Script API.', ''];
for (const [name, t] of Object.entries(S)) {
  out.push(`## ${name}`, '', `Access: ${t.access}. Primary key: \`${t.columns[0][0]}\`.`, '',
    '| Column | Type | Required | Notes |', '|---|---|---|---|');
  for (const [c, ty, req, notes] of t.columns) out.push(`| ${c} | ${ty} | ${req ? 'yes' : ''} | ${notes} |`);
  out.push('');
}
process.stdout.write(out.join('\n'));
