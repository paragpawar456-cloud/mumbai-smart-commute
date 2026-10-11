// Pulls stations, bus stops and taxi/auto stands for the pilot area from
// OpenStreetMap (Overpass API) and writes data/osm/*.json.
// Data © OpenStreetMap contributors, ODbL 1.0. Run with Node 18+:
//   node tool/osm/extract.mjs
// Runs in GitHub Actions (.github/workflows/osm-extract.yml) so results are
// reproducible; it is not called by the app at runtime.
import { writeFile, mkdir } from 'node:fs/promises';

const ENDPOINT = process.env.OVERPASS_URL || 'https://overpass-api.de/api/interpreter';
const UA = 'mumbai-smart-commute-data-extract/1.0 (+https://github.com/paragpawar456-cloud/mumbai-smart-commute)';

// Mumbai Metropolitan Region rail corridor, south Mumbai to Kalyan/Badlapur.
const RAIL_BBOX = '18.89,72.79,19.30,73.25';
// Last-mile area: Thane to Kalyan and Dombivli, including Manpada and Yogidham.
// (The files keep their kalyan_* names so older tools still find them.)
const KALYAN_BBOX = '19.16,72.94,19.30,73.18';

const QUERIES = {
  rail_stations: `
    [out:json][timeout:120];
    (
      node["railway"~"^(station|halt)$"](${RAIL_BBOX});
      way["railway"="station"](${RAIL_BBOX});
      node["public_transport"="station"]["train"="yes"](${RAIL_BBOX});
      node["public_transport"="station"]["subway"="yes"](${RAIL_BBOX});
      node["public_transport"="station"]["light_rail"="yes"](${RAIL_BBOX});
      node["public_transport"="station"]["monorail"="yes"](${RAIL_BBOX});
    );
    out tags center;`,
  kalyan_bus_stops: `
    [out:json][timeout:120];
    (
      node["highway"="bus_stop"](${KALYAN_BBOX});
      node["public_transport"="platform"]["bus"="yes"](${KALYAN_BBOX});
      node["amenity"="bus_station"](${KALYAN_BBOX});
      way["amenity"="bus_station"](${KALYAN_BBOX});
    );
    out tags center;`,
  kalyan_pickup_points: `
    [out:json][timeout:120];
    (
      node["amenity"="taxi"](${KALYAN_BBOX});
      way["amenity"="taxi"](${KALYAN_BBOX});
      node["amenity"="auto_rickshaw"](${KALYAN_BBOX});
      node["amenity"="auto_rickshaw_stand"](${KALYAN_BBOX});
    );
    out tags center;`,
  kalyan_places: `
    [out:json][timeout:120];
    (
      node["name"~"Yogidham",i](${KALYAN_BBOX});
      way["name"~"Yogidham",i](${KALYAN_BBOX});
      node["place"](${KALYAN_BBOX});
    );
    out tags center;`,
};

async function run(name, query) {
  for (let attempt = 1; attempt <= 3; attempt++) {
    const res = await fetch(ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': UA },
      body: 'data=' + encodeURIComponent(query),
    });
    if (res.ok) return res.json();
    console.error(`${name}: HTTP ${res.status} (attempt ${attempt})`);
    await new Promise((r) => setTimeout(r, 15000 * attempt));
  }
  throw new Error(`${name}: Overpass failed`);
}

function simplify(el) {
  const lat = el.lat ?? el.center?.lat;
  const lon = el.lon ?? el.center?.lon;
  return { osm: `${el.type}/${el.id}`, lat, lon, tags: el.tags || {} };
}

await mkdir('data/osm', { recursive: true });
const meta = { source: 'OpenStreetMap via Overpass API', licence: 'ODbL 1.0',
               attribution: '© OpenStreetMap contributors', endpoint: ENDPOINT,
               extracted_at: new Date().toISOString(), files: {} };
for (const [name, q] of Object.entries(QUERIES)) {
  const json = await run(name, q);
  const rows = json.elements.map(simplify).filter((r) => r.lat != null);
  await writeFile(`data/osm/${name}.json`, JSON.stringify(rows, null, 1) + '\n');
  meta.files[name] = { count: rows.length, osm_base: json.osm3s?.timestamp_osm_base };
  console.log(`${name}: ${rows.length}`);
  await new Promise((r) => setTimeout(r, 5000)); // be polite to the shared server
}
await writeFile('data/osm/_meta.json', JSON.stringify(meta, null, 1) + '\n');
