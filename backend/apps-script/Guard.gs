/** Rate limiting and duplicate-request protection via CacheService. */
var Guard = (function () {
  /** Allows `limit` calls per `windowSec` for a key; approximate, by design. */
  function rateLimit(key, limit, windowSec) {
    var cache = CacheService.getScriptCache();
    var bucket = 'rl:' + key + ':' + Math.floor(Date.now() / 1000 / windowSec);
    var n = Number(cache.get(bucket) || 0) + 1;
    cache.put(bucket, String(n), windowSec + 5);
    if (n > limit) throw new ApiError('rate_limited', 'Too many requests, slow down');
  }

  /** Returns a cached response if this requestId was already handled. */
  function replay(requestId) {
    if (!requestId) return null;
    var hit = CacheService.getScriptCache().get('req:' + requestId);
    return hit ? JSON.parse(hit) : null;
  }

  function remember(requestId, response) {
    if (!requestId) return;
    var s = JSON.stringify(response);
    if (s.length < 90000) CacheService.getScriptCache().put('req:' + requestId, s, 600);
  }

  return { rateLimit: rateLimit, replay: replay, remember: remember };
})();
