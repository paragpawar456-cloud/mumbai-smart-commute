/**
 * Optional road distance via openrouteservice (free key, 2,000 requests/day).
 * Set script property ORS_API_KEY to enable. Without it, or when ORS fails,
 * the app falls back to its own labelled straight-line estimate.
 * Results are cached for 7 days per rounded origin/destination pair.
 */
function handleRoadDistance(ctx) {
  var p = ctx.payload;
  var from = [coord_(p.fromLat, 'fromLat', 18.8, 19.9), coord_(p.fromLng, 'fromLng', 72.7, 73.5)];
  var to = [coord_(p.toLat, 'toLat', 18.8, 19.9), coord_(p.toLng, 'toLng', 72.7, 73.5)];
  var key = PropertiesService.getScriptProperties().getProperty('ORS_API_KEY');
  if (!key) return { available: false };
  var cacheKey = 'road:' + from.join(',') + ':' + to.join(',');
  var cache = CacheService.getScriptCache();
  var hit = cache.get(cacheKey);
  if (hit) return JSON.parse(hit);
  try {
    var res = UrlFetchApp.fetch('https://api.openrouteservice.org/v2/directions/driving-car', {
      method: 'post',
      contentType: 'application/json',
      headers: { Authorization: key },
      payload: JSON.stringify({ coordinates: [[from[1], from[0]], [to[1], to[0]]] }),
      muteHttpExceptions: true,
    });
    if (res.getResponseCode() !== 200) {
      console.warn('ORS ' + res.getResponseCode());
      return { available: false };
    }
    var s = JSON.parse(res.getContentText()).routes[0].summary;
    var out = {
      available: true,
      km: Math.round(s.distance / 10) / 100,
      driveMinutes: Math.ceil(s.duration / 60),
      source: 'openrouteservice',
      attribution: '© openrouteservice.org by HeiGIT | © OpenStreetMap contributors',
      retrievedAt: new Date().toISOString(),
    };
    cache.put(cacheKey, JSON.stringify(out), 21600);
    return out;
  } catch (e) {
    console.warn('ORS failed: ' + e);
    return { available: false };
  }
}
