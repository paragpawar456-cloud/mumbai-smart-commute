/** Input validation helpers. Throw ApiError('invalid_input') on failure. */
var Validate = {
  string: function (v, field, opts) {
    opts = opts || {};
    if (v === undefined || v === null || v === '') {
      if (opts.required) throw new ApiError('invalid_input', field + ' is required');
      return '';
    }
    if (typeof v !== 'string') throw new ApiError('invalid_input', field + ' must be text');
    var s = v.trim().replace(/[\u0000-\u001F\u007F]/g, '');
    if (opts.max && s.length > opts.max) throw new ApiError('invalid_input', field + ' too long');
    // Block spreadsheet formula injection.
    if (/^[=+\-@]/.test(s)) s = "'" + s;
    return s;
  },
  oneOf: function (v, field, allowed) {
    if (allowed.indexOf(v) === -1) throw new ApiError('invalid_input', field + ' is not valid');
    return v;
  },
  int: function (v, field, min, max) {
    var n = Number(v);
    if (!Number.isInteger(n) || n < min || n > max) throw new ApiError('invalid_input', field + ' out of range');
    return n;
  },
};
