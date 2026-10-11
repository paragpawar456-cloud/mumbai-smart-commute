/**
 * Firebase ID token verification.
 *
 * Apps Script has no RS256 verify primitive, so we ask Firebase itself:
 * identitytoolkit accounts:lookup accepts the ID token and returns the user
 * only if the token is valid and unexpired. Results are cached by a hash of
 * the token for up to 10 minutes (well under the 1 h token lifetime) to stay
 * far inside the 20,000 UrlFetch/day consumer quota.
 *
 * Script Property required: FIREBASE_WEB_API_KEY (public Web API key).
 */
var Auth = (function () {
  var LOOKUP = 'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=';

  function hash_(s) {
    return Utilities.base64EncodeWebSafe(
      Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, s));
  }

  function verify(idToken) {
    if (!idToken || typeof idToken !== 'string' || idToken.length > 4096) {
      throw new ApiError('unauthenticated', 'Sign in required');
    }
    var cache = CacheService.getScriptCache();
    var key = 'tok:' + hash_(idToken);
    var hit = cache.get(key);
    if (hit) return JSON.parse(hit);

    var apiKey = PropertiesService.getScriptProperties().getProperty('FIREBASE_WEB_API_KEY');
    if (!apiKey) throw new ApiError('server_error', 'Auth not configured');
    var res = UrlFetchApp.fetch(LOOKUP + encodeURIComponent(apiKey), {
      method: 'post',
      contentType: 'application/json',
      payload: JSON.stringify({ idToken: idToken }),
      muteHttpExceptions: true,
    });
    if (res.getResponseCode() !== 200) throw new ApiError('unauthenticated', 'Invalid or expired session');
    var users = JSON.parse(res.getContentText()).users || [];
    if (users.length !== 1) throw new ApiError('unauthenticated', 'Invalid session');
    var u = users[0];
    if (u.disabled) throw new ApiError('forbidden', 'Account disabled');
    var principal = { uid: u.localId, email: u.email || '', emailVerified: !!u.emailVerified };
    cache.put(key, JSON.stringify(principal), 600);
    return principal;
  }

  /** Returns the Users row, creating it on first authenticated call. */
  function userRecord(principal) {
    var row = Db.findOne('Users', 'uid', principal.uid);
    if (row) {
      if (row.status !== 'active') throw new ApiError('forbidden', 'Account ' + row.status);
      return row;
    }
    return Db.withLock(function () {
      var again = Db.findOne('Users', 'uid', principal.uid);
      if (again) return again;
      var now = new Date().toISOString();
      Db.append('Users', {
        uid: principal.uid, email: principal.email, display_name: '',
        preferred_language: 'en', role: 'user', status: 'active',
        consent_version: '', created_at: now, updated_at: now, last_seen_at: now.slice(0, 10),
      });
      return Db.findOne('Users', 'uid', principal.uid);
    });
  }

  /** Role comes from the Sheet only, never from the request. */
  function requireRole(user, roles) {
    if (roles.indexOf(user.role) === -1) throw new ApiError('forbidden', 'Not allowed');
  }

  return { verify: verify, userRecord: userRecord, requireRole: requireRole };
})();
