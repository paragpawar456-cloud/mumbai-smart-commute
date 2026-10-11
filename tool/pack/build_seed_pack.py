#!/usr/bin/env python3
"""Builds assets/data/seed_pack.json and data/templates/*.csv for the pilot.

Station coordinates and Marathi/Hindi names come from the OpenStreetMap
extract in data/osm (ODbL). Line order is the public station sequence of each
line. No timetable rows are generated here: trips and stop times must come
from an official timetable entered via the CSV templates.

Usage: python3 tool/pack/build_seed_pack.py
"""
import csv
import json
import os
from datetime import datetime, timezone

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OSM = json.load(open(os.path.join(ROOT, 'data/osm/rail_stations.json')))
OSM_META = json.load(open(os.path.join(ROOT, 'data/osm/_meta.json')))

# station_id -> OSM element id (picked by hand where a name has several nodes).
CR_MAIN = [
    ('CSMT', 'node/12176277888'), ('MSD', 'node/12171122260'), ('SNRD', 'node/2178163576'),
    ('BY', 'node/2630075001'), ('CHG', 'node/3501418211'), ('CRD', 'node/2444001671'),
    ('PR', 'node/3501418212'), ('DR', 'node/2630075003'), ('MTN', 'node/4264457295'),
    ('SIN', 'node/2663263713'), ('CLA', 'node/2663447640'), ('VVH', 'node/620013256'),
    ('GC', 'node/4264539430'), ('VK', 'node/4258411797'), ('KJRD', 'node/619992025'),
    ('BND', 'node/3248305759'), ('NHU', 'node/2629791007'), ('MLND', 'node/1643351703'),
    ('TNA', 'node/246582717'), ('KLVA', 'node/619119023'), ('MBQ', 'node/1369351423'),
    ('DIVA', 'node/630743879'), ('KOPR', 'node/4548421106'), ('DI', 'node/4548420708'),
    ('THK', 'node/2441333898'), ('KYN', 'node/4548442653'),
]
METRO_1 = [
    ('M1-VER', 'way/287299861'), ('M1-DNN', 'way/287299866'), ('M1-AZN', 'way/331815667'),
    ('M1-AND', 'node/6020955334'), ('M1-WEH', 'way/331815671'), ('M1-CHK', 'way/331824153'),
    ('M1-APR', 'way/311841874'), ('M1-MRL', 'way/311841876'), ('M1-SKN', 'way/331824155'),
    ('M1-ASL', 'way/331827626'), ('M1-JGN', 'way/311841875'), ('M1-GKP', 'way/151205149'),
]
# Clean English display names where the OSM name carries a disambiguator.
NAME_OVERRIDES = {'M1-AND': 'Andheri', 'M1-GKP': 'Ghatkopar', 'CSMT': 'CSMT (Mumbai)',
                  'DIVA': 'Diva', 'KYN': 'Kalyan'}

LINES = [
    dict(route_id='CR-MAIN', operator='CR', mode='suburban',
         name_en='Central Line (CSMT – Kalyan)', color='#1565C0', ids=CR_MAIN),
    dict(route_id='MML1', operator='MMOPL', mode='metro',
         name_en='Metro Line 1 (Versova – Ghatkopar)', color='#6A1B9A', ids=METRO_1),
]
# Walking transfers between different stations, minutes estimated from the
# straight-line distance (~115 m) plus stairs; adjust when verified on site.
INTERCHANGES = [('GC', 'M1-GKP', 5)]

by_osm = {r['osm']: r for r in OSM}
now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def station_row(sid, osm_id):
    r = by_osm[osm_id]
    t = r['tags']
    return {
        'station_id': sid,
        'name_en': NAME_OVERRIDES.get(sid, t['name']),
        'name_mr': t.get('name:mr', ''),
        'name_hi': t.get('name:hi', ''),
        'modes': 'metro' if sid.startswith('M1-') else 'suburban',
        'lat': round(r['lat'], 6),
        'lng': round(r['lon'], 6),
        'facilities': '',
        'source_id': 'osm',
        'verified_at': '',
        '_osm': osm_id,
    }


stations, seen = [], set()
for line in LINES:
    for sid, osm_id in line['ids']:
        if sid not in seen:
            stations.append(station_row(sid, osm_id))
            seen.add(sid)

lines = [{
    'route_id': l['route_id'], 'operator': l['operator'], 'mode': l['mode'],
    'name_en': l['name_en'], 'color': l['color'],
    'station_sequence': ','.join(s for s, _ in l['ids']), 'source_id': 'curated-network',
} for l in LINES]

sources = [
    {'source_id': 'osm', 'name': 'OpenStreetMap', 'url': 'https://www.openstreetmap.org/copyright',
     'licence': 'ODbL 1.0', 'attribution': '© OpenStreetMap contributors',
     'update_frequency': 'manual extract', 'notes': f"extracted {OSM_META['extracted_at']}"},
    {'source_id': 'curated-network', 'name': 'Station order per line (public route maps)', 'url': '',
     'licence': 'facts', 'attribution': '', 'update_frequency': 'on change',
     'notes': 'Sequence only; no timetable'},
]

pack = {
    'version': 1,
    'generated_at': now,
    'sources': [{k: s[k] for k in ('source_id', 'name', 'licence', 'attribution', 'url')} for s in sources],
    'stations': [{k: v for k, v in s.items() if not k.startswith('_')} for s in stations],
    'lines': lines,
    'interchanges': [{'from_station_id': a, 'to_station_id': b, 'walk_minutes': m} for a, b, m in INTERCHANGES],
    'trips': [],
    'stop_times': [],
}
with open(os.path.join(ROOT, 'assets/data/seed_pack.json'), 'w', encoding='utf-8') as f:
    json.dump(pack, f, ensure_ascii=False, indent=1)
    f.write('\n')


def write_csv(name, header, rows):
    with open(os.path.join(ROOT, 'data/templates', name), 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)


write_csv('Stations.csv', ['station_id', 'name_en', 'name_mr', 'name_hi', 'modes', 'lat', 'lng',
                           'facilities', 'source_id', 'verified_at'],
          [[s[k] for k in ('station_id', 'name_en', 'name_mr', 'name_hi', 'modes', 'lat', 'lng',
                           'facilities', 'source_id', 'verified_at')] for s in stations])
write_csv('TrainRoutes.csv', list(lines[0].keys()), [list(l.values()) for l in lines])
write_csv('Interchanges.csv', ['from_station_id', 'to_station_id', 'walk_minutes', 'source_id'],
          [[a, b, m, 'curated-network'] for a, b, m in INTERCHANGES])
write_csv('DataSources.csv', list(sources[0].keys()), [list(s.values()) for s in sources])
# Empty timetable templates with one commented example row to show the format.
write_csv('TrainTrips.csv', ['trip_id', 'route_id', 'train_number', 'direction', 'service_days',
                             'train_type', 'ac', 'ladies_special', 'cars', 'valid_from', 'valid_to',
                             'source_id'], [])
write_csv('TripStopTimes.csv', ['trip_id', 'seq', 'station_id', 'arrival', 'departure', 'platform'], [])
print(f"{len(stations)} stations, {len(lines)} lines -> assets/data/seed_pack.json")
