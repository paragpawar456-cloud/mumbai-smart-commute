#!/usr/bin/env python3
"""Builds assets/data/seed_pack.json and data/templates/*.csv for the pilot.

Station coordinates and Marathi/Hindi names come from the OpenStreetMap
extract in data/osm (ODbL). Line order is the public station sequence of each
line. Trips and stop times come only from an official timetable: the Central
Railway Main Line PDFs converted by tool/pack/import_cr_timetable.py.

Usage: python3 tool/pack/build_seed_pack.py
"""
import csv
import json
import os
from datetime import datetime, timezone

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OSM = json.load(open(os.path.join(ROOT, 'data/osm/rail_stations.json')))
OSM_META = json.load(open(os.path.join(ROOT, 'data/osm/_meta.json')))
OSM_PLACES = {r['osm']: r for r in json.load(open(os.path.join(ROOT, 'data/osm/kalyan_places.json')))}
OSM_PICKUPS = json.load(open(os.path.join(ROOT, 'data/osm/kalyan_pickup_points.json')))

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

# Last-mile pilot: Kalyan. Places are destinations people search for.
# (place_id, OSM id, kind, Marathi name if not in OSM)
PLACES = [
    ('P-YOGIDHAM', 'way/1413460408', 'housing', 'योगीधाम'),
    ('P-YOGIDHAM-3', 'way/1411150860', 'housing', 'योगीधाम फेज ३'),
    ('P-KALYAN-W', 'node/10247312859', 'suburb', 'कल्याण पश्चिम'),
    ('P-KALYAN-E', 'node/10247312858', 'suburb', 'कल्याण पूर्व'),
    ('P-AADHARWADI', 'node/2629924559', 'suburb', 'आधारवाडी'),
    ('P-KHADAKPADA', 'node/2629924562', 'suburb', 'खडकपाडा'),
    ('P-VITTHALWADI', 'node/1682314548', 'suburb', 'विठ्ठलवाडी'),
]

# Auto and taxi meter fares. These values were reported by Time Out Mumbai and
# Mid-Day for the MMRTA revision effective 1 Sep 2026; the official tariff card
# was not reachable, so the source says "reported" and the app shows every
# fare as an estimate.
FARE_RULES = [
    dict(fare_rule_id='AUTO-MMR-2026-09', mode='auto', region='MMR', min_fare_inr=27, min_km=1.5,
         per_km_inr=18.22, night_multiplier=1.25, night_start='00:00', night_end='05:00',
         effective_from='2026-09-01', source_id='mmrta-2026-reported'),
    dict(fare_rule_id='TAXI-MMR-2026-09', mode='taxi', region='MMR', min_fare_inr=33, min_km=1.5,
         per_km_inr=21.90, night_multiplier=1.25, night_start='00:00', night_end='05:00',
         effective_from='2026-09-01', source_id='mmrta-2026-reported'),
]

# Booking links only: the provider's own app shows the real price.
PROVIDERS = [
    dict(provider_id='uber', name='Uber', categories='auto,bike,cab', integration='deep_link',
         android_package='com.ubercab',
         link_template='https://m.uber.com/ul/?action=setPickup'
                       '&pickup%5Blatitude%5D={plat}&pickup%5Blongitude%5D={plng}'
                       '&dropoff%5Blatitude%5D={dlat}&dropoff%5Blongitude%5D={dlng}'
                       '&dropoff%5Bnickname%5D={dname}',
         active=True, source_id='uber-universal-link'),
    dict(provider_id='ola', name='Ola', categories='auto,bike,cab', integration='open_app',
         android_package='com.olacabs.customer', link_template='', active=True, source_id=''),
    dict(provider_id='rapido', name='Rapido', categories='auto,bike,cab', integration='open_app',
         android_package='com.rapido.passenger', link_template='', active=True, source_id=''),
]

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
    {'source_id': 'mmrta-2026-reported', 'name': 'MMRTA auto/taxi fare revision (as reported)',
     'url': 'https://www.timeout.com/mumbai/news/mumbai-auto-and-taxi-fares-rise-from-september-1-check-the-new-rates-090126',
     'licence': 'facts', 'attribution': 'Fares as reported by Time Out Mumbai and Mid-Day',
     'update_frequency': 'on revision',
     'notes': 'Replace with the official MMRTA tariff card when available'},
    {'source_id': 'uber-universal-link', 'name': 'Uber universal link format', 'url': 'https://developer.uber.com/',
     'licence': 'link format only', 'attribution': '', 'update_frequency': 'on change',
     'notes': 'Opens the Uber app with the trip filled in; no prices are read'},
]

places = []
for pid, osm_id, kind, name_mr in PLACES:
    r = OSM_PLACES[osm_id]
    places.append({
        'place_id': pid, 'name_en': r['tags']['name'],
        'name_mr': r['tags'].get('name:mr', name_mr), 'name_hi': r['tags'].get('name:hi', ''),
        'kind': kind, 'lat': round(r['lat'], 6), 'lng': round(r['lon'], 6),
        'near_station_id': 'KYN', 'source_id': 'osm',
    })

pickups = []
for i, r in enumerate(OSM_PICKUPS, 1):
    t = r['tags']
    kind = 'auto_stand' if t.get('taxi_vehicle') == 'auto_rickshaw' else 'taxi_stand'
    pickups.append({
        'pickup_id': f'OSM-{r["osm"].replace("/", "-")}', 'kind': kind,
        'name_en': t.get('name') or ('Auto stand' if kind == 'auto_stand' else 'Taxi stand'),
        'lat': round(r['lat'], 6), 'lng': round(r['lon'], 6), 'near_station_id': '',
        'destinations': '', 'shared_fare_inr': None, 'fare_source': '', 'verification': 'osm',
        'verified_at': '', 'source_id': 'osm',
    })

# Central Railway Main Line trains, made by tool/pack/import_cr_timetable.py
# from the official pocket timetable PDFs in data/timetables/cr.
_TT_PATH = os.path.join(ROOT, 'data/timetables/cr/cr_main_timetable.json')
TIMETABLE = json.load(open(_TT_PATH)) if os.path.exists(_TT_PATH) else {'trips': [], 'stop_times': []}
if TIMETABLE['trips']:
    _m = json.load(open(os.path.join(ROOT, 'data/timetables/cr/manifest.json')))
    sources.append({'source_id': _m['source_id'], 'name': _m['name'], 'licence': _m['licence'],
                    'attribution': _m['attribution'], 'url': _m['url']})

pack = {
    'version': 3,
    'generated_at': now,
    'sources': [{k: s[k] for k in ('source_id', 'name', 'licence', 'attribution', 'url')} for s in sources],
    'stations': [{k: v for k, v in s.items() if not k.startswith('_')} for s in stations],
    'lines': lines,
    'interchanges': [{'from_station_id': a, 'to_station_id': b, 'walk_minutes': m} for a, b, m in INTERCHANGES],
    'trips': TIMETABLE['trips'],
    'stop_times': TIMETABLE['stop_times'],
    'places': places,
    'pickup_points': pickups,
    'bus_stops': [],
    'bus_routes': [],
    'fare_rules': FARE_RULES,
    'providers': [{k: v for k, v in p.items() if k not in ('active', 'source_id')} for p in PROVIDERS],
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
write_csv('Places.csv', list(places[0].keys()), [list(p.values()) for p in places])
write_csv('PickupPoints.csv', list(pickups[0].keys()),
          [['' if v is None else v for v in p.values()] for p in pickups])
write_csv('FareRules.csv', ['fare_rule_id', 'mode', 'region', 'min_fare_inr', 'min_km', 'per_km_inr',
                            'night_multiplier', 'night_start', 'night_end', 'slab_json', 'effective_from',
                            'source_id'],
          [[f.get(k, '') for k in ('fare_rule_id', 'mode', 'region', 'min_fare_inr', 'min_km', 'per_km_inr',
                                   'night_multiplier', 'night_start', 'night_end', 'slab_json',
                                   'effective_from', 'source_id')] for f in FARE_RULES])
write_csv('TransportProviders.csv', list(PROVIDERS[0].keys()),
          [['TRUE' if v is True else v for v in p.values()] for p in PROVIDERS])
write_csv('BusStops.csv', ['stop_id', 'name_en', 'name_mr', 'lat', 'lng', 'operators', 'source_id'], [])
write_csv('BusRoutes.csv', ['bus_route_id', 'operator', 'route_number', 'name_en', 'stop_sequence',
                            'frequency_note', 'first_departure', 'last_departure', 'source_id'], [])
print(f"{len(places)} places, {len(pickups)} pickup points, {len(FARE_RULES)} fare rules")
print(f"{len(stations)} stations, {len(lines)} lines -> assets/data/seed_pack.json")
