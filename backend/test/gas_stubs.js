// In-memory stand-ins for the Apps Script services the backend uses.
'use strict';
const crypto = require('crypto');

function makeSpreadsheet() {
  const sheets = new Map();
  function makeSheet(name) {
    const rows = [];
    const sheet = {
      getName: () => name,
      getLastRow: () => rows.length,
      getLastColumn: () => rows.reduce((m, r) => Math.max(m, r.length), 0),
      appendRow: (r) => rows.push(r.slice()),
      deleteRow: (n) => rows.splice(n - 1, 1),
      setFrozenRows: () => sheet,
      getRange: (r, c, nr, nc) => ({
        getValues: () => Array.from({ length: nr }, (_, i) =>
          Array.from({ length: nc }, (_, j) => ((rows[r - 1 + i] || [])[c - 1 + j] ?? ''))),
        setValues: (vals) => {
          vals.forEach((v, i) => {
            rows[r - 1 + i] = rows[r - 1 + i] || [];
            v.forEach((x, j) => { rows[r - 1 + i][c - 1 + j] = x; });
          });
          return { setFontWeight: () => {} };
        },
      }),
      _rows: rows,
    };
    return sheet;
  }
  const ss = {
    getSheetByName: (n) => sheets.get(n) || null,
    insertSheet: (n) => { const s = makeSheet(n); sheets.set(n, s); return s; },
    getSheets: () => [...sheets.values()],
    deleteSheet: (s) => sheets.delete(s.getName()),
  };
  return ss;
}

function makeCache() {
  const m = new Map();
  return {
    get: (k) => (m.has(k) ? m.get(k) : null),
    put: (k, v) => m.set(k, v),
    getAll: (keys) => Object.fromEntries(keys.filter((k) => m.has(k)).map((k) => [k, m.get(k)])),
    putAll: (obj) => Object.entries(obj).forEach(([k, v]) => m.set(k, v)),
    _m: m,
  };
}

function makeGlobals({ lookup } = {}) {
  const ss = makeSpreadsheet();
  const cache = makeCache();
  const fetches = [];
  const props = { FIREBASE_WEB_API_KEY: 'test-key' };
  return {
    console,
    JSON, Date, Math, Number, String, Object, Array, Error,
    SpreadsheetApp: { getActiveSpreadsheet: () => ss },
    CacheService: { getScriptCache: () => cache },
    LockService: { getScriptLock: () => ({ tryLock: () => true, releaseLock: () => {} }) },
    PropertiesService: { getScriptProperties: () => ({ getProperty: (k) => props[k] || null }) },
    Utilities: {
      DigestAlgorithm: { SHA_256: 'sha256' },
      computeDigest: (alg, s) => [...crypto.createHash('sha256').update(s).digest()],
      base64EncodeWebSafe: (bytes) => Buffer.from(bytes).toString('base64url'),
    },
    UrlFetchApp: {
      fetch: (url, opts) => {
        fetches.push({ url, opts });
        const { code, body } = lookup(JSON.parse(opts.payload).idToken);
        return { getResponseCode: () => code, getContentText: () => JSON.stringify(body) };
      },
    },
    ContentService: {
      MimeType: { JSON: 'json' },
      createTextOutput: (s) => ({ setMimeType: () => ({ content: s }) }),
    },
    _ss: ss, _cache: cache, _fetches: fetches,
  };
}

module.exports = { makeGlobals };
