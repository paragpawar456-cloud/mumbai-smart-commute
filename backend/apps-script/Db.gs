/**
 * Minimal row <-> object helpers over the bound spreadsheet.
 * All writes go through withLock() so concurrent requests can't interleave.
 */
var Db = (function () {
  function sheet_(name) {
    var s = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name);
    if (!s) throw new ApiError('server_error', 'Missing tab ' + name + '; run setupSheets()');
    return s;
  }

  function headers_(name) {
    return SCHEMA[name].columns.map(function (c) { return c[0]; });
  }

  function all(name) {
    var s = sheet_(name);
    var last = s.getLastRow();
    if (last < 2) return [];
    var h = headers_(name);
    return s.getRange(2, 1, last - 1, h.length).getValues().map(function (row, i) {
      var o = { _row: i + 2 };
      h.forEach(function (k, j) { o[k] = row[j]; });
      return o;
    });
  }

  function findOne(name, key, value) {
    var rows = all(name);
    for (var i = 0; i < rows.length; i++) if (String(rows[i][key]) === String(value)) return rows[i];
    return null;
  }

  function append(name, valuesOrObject) {
    var h = headers_(name);
    var row = Array.isArray(valuesOrObject) ? valuesOrObject
      : h.map(function (k) { return valuesOrObject[k] === undefined ? '' : valuesOrObject[k]; });
    sheet_(name).appendRow(row);
  }

  function update(name, rowNumber, patch) {
    var h = headers_(name);
    var s = sheet_(name);
    var range = s.getRange(rowNumber, 1, 1, h.length);
    var current = range.getValues()[0];
    var next = h.map(function (k, j) { return patch.hasOwnProperty(k) ? patch[k] : current[j]; });
    range.setValues([next]);
  }

  function deleteWhere(name, key, value) {
    var s = sheet_(name);
    var rows = all(name).filter(function (r) { return String(r[key]) === String(value); });
    // Bottom-up so row numbers stay valid.
    rows.reverse().forEach(function (r) { s.deleteRow(r._row); });
    return rows.length;
  }

  function withLock(fn) {
    var lock = LockService.getScriptLock();
    if (!lock.tryLock(10000)) throw new ApiError('busy', 'Server busy, try again');
    try { return fn(); } finally { lock.releaseLock(); }
  }

  return { all: all, findOne: findOne, append: append, update: update,
           deleteWhere: deleteWhere, withLock: withLock };
})();
