#!/usr/bin/env python3
"""Turns Central Railway's official Main Line suburban pocket timetable PDFs
into trips and stop times for the data pack.

Source PDFs (published by Central Railway, w.e.f. 5 Oct 2024) are kept in
data/timetables/cr/ with their official URLs and SHA-256 in manifest.json.
Only stations on the app's CSMT-Kalyan line are kept; each trip remembers
where it really starts and ends (e.g. Kasara) for "towards ...".

Legend (from the same timetable): X = not on Sunday/holiday, XX = not on
Saturday/Sunday/holiday, AC = air-conditioned rake. A "…" means the train
runs through without stopping.

Fails loudly on anything it can't place, so a changed layout never turns
into wrong times silently.

Usage: python3 tool/pack/import_cr_timetable.py
"""
import hashlib
import json
import os
import re
import sys

import pdfplumber

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DIR = os.path.join(ROOT, 'data/timetables/cr')
MANIFEST = json.load(open(os.path.join(DIR, 'manifest.json')))

# Timetable spelling -> app station id (CSMT-Kalyan main line).
PACK = {
    'CSMT': 'CSMT', 'Masjid': 'MSD', 'Sandhurst Road': 'SNRD', 'Byculla': 'BY',
    'Chinchpokli': 'CHG', 'Currey Road': 'CRD', 'Parel': 'PR', 'Dadar': 'DR',
    'Matunga': 'MTN', 'Sion': 'SIN', 'Kurla': 'CLA', 'Vidyavihar': 'VVH',
    'Ghatkopar': 'GC', 'Vikhroli': 'VK', 'Kanjur Marg': 'KJRD', 'Bhandup': 'BND',
    'Nahur': 'NHU', 'Mulund': 'MLND', 'Thane': 'TNA', 'Kalva': 'KLVA',
    'Mumbra': 'MBQ', 'Diva': 'DIVA', 'Kopar': 'KOPR', 'Dombivli': 'DI',
    'Thakurli': 'THK', 'Kalyan': 'KYN',
}
# Stations beyond Kalyan: only used to name where a train starts or ends.
BEYOND = {
    'Vithalwadi', 'Ulhas Nagar', 'Ambernath', 'Badlapur', 'Vangani', 'Shelu',
    'Neral', 'Bhivpuri Road', 'Karjat', 'Palasdhari', 'Kelavli', 'Dolavli',
    'Lowjee', 'Khopoli', 'Shahad', 'Ambivli', 'Titwala', 'Khadavli', 'Vasind',
    'Asangaon', 'Atgaon', 'Thansit', 'Khardi', 'Umbermalli', 'Umbermali', 'Kasara',
}
ALIASES = {'Umbermali': 'Umbermalli', 'Diwa': 'Diva'}
# Spelling in the PDFs varies in case ("Bhivpuri road"), so match on lower case.
CANON = {n.lower(): n for n in [*PACK, *BEYOND]}
LINE = 'CR-MAIN'
ORDER = list(PACK.values())
TIME = re.compile(r'^\d{1,2}:\d{2}$')
NUM = re.compile(r'^\d{5}$')


def fail(msg):
    sys.exit(f'import_cr_timetable: {msg}')


def rows_of(page):
    # Words on one printed line can sit a point or two apart vertically.
    rows = []
    for w in sorted(page.extract_words(), key=lambda w: w['top']):
        if rows and w['top'] - rows[-1][0]['top'] <= 3:
            rows[-1].append(w)
        else:
            rows.append([w])
    return [sorted(r, key=lambda w: w['x0']) for r in rows]


def parse_page(page, direction):
    rows = rows_of(page)
    head_i = next((i for i, r in enumerate(rows)
                   if sum(1 for w in r if NUM.match(w['text'])) >= 3), None)
    if head_i is None:
        return []
    cols = [w for w in rows[head_i] if NUM.match(w['text'])]
    centers = [(w['x0'] + w['x1']) / 2 for w in cols]
    half = min(b - a for a, b in zip(centers, centers[1:])) / 2 if len(centers) > 1 else 15
    name_right = cols[0]['x0'] - 1

    def col_of(w):
        c = (w['x0'] + w['x1']) / 2
        i = min(range(len(centers)), key=lambda k: abs(centers[k] - c))
        if abs(centers[i] - c) > half:
            fail(f'page {page.page_number}: "{w["text"]}" at x={c:.0f} fits no column')
        return i

    trains = [{'number': w['text'], 'marks': set(), 'stops': []} for w in cols]
    for r in rows[head_i + 1:]:
        left = [w for w in r if w['x1'] <= name_right]
        right = [w for w in r if w['x1'] > name_right]
        name = ' '.join(w['text'] for w in left).strip()
        name = CANON.get(ALIASES.get(name, name).lower(), name)
        if not name:
            # Code row (e.g. "A 1") or marks row (X, XX, AC, $) above the times.
            for w in right:
                if w['text'] in ('X', 'XX', 'AC', '$'):
                    trains[col_of(w)]['marks'].add(w['text'])
            continue
        if name not in PACK and name not in BEYOND:
            if any(TIME.match(w['text']) for w in right):
                fail(f'page {page.page_number}: unknown station "{name}"')
            continue
        for w in right:
            if TIME.match(w['text']):
                h, m = map(int, w['text'].split(':'))
                trains[col_of(w)]['stops'].append((name, h * 60 + m))
    for t in trains:
        t['direction'] = direction
    return [t for t in trains if t['stops']]


def build():
    trips, stop_times, seen = [], [], set()
    for src in MANIFEST['files']:
        path = os.path.join(DIR, src['file'])
        digest = hashlib.sha256(open(path, 'rb').read()).hexdigest()
        if digest != src['sha256']:
            fail(f'{src["file"]}: SHA-256 changed; check the new PDF and update manifest.json')
        with pdfplumber.open(path) as pdf:
            for page in pdf.pages:
                for t in parse_page(page, src['direction']):
                    # Times only ever move forward; a smaller one means midnight passed.
                    fixed, prev = [], None
                    for name, m in t['stops']:
                        while prev is not None and m < prev:
                            if prev - m > 12 * 60:
                                m += 24 * 60
                            else:
                                fail(f'train {t["number"]}: time goes backwards at {name}')
                        fixed.append((name, m))
                        prev = m
                    pack_stops = [(PACK[n], m) for n, m in fixed if n in PACK]
                    if len(pack_stops) < 2:
                        continue
                    ids = [s for s, _ in pack_stops]
                    want = ORDER if src['direction'] == 'down' else ORDER[::-1]
                    if ids != [s for s in want if s in ids]:
                        fail(f'train {t["number"]}: stations out of order {ids}')
                    first = want.index(ids[0])
                    last = want.index(ids[-1])
                    skipped = set(want[first:last + 1]) - set(ids)
                    trip_id = f'CR-{t["number"]}'
                    if trip_id in seen:
                        fail(f'train {t["number"]} appears twice')
                    seen.add(trip_id)
                    days = ('MON-FRI' if 'XX' in t['marks'] else
                            'MON-SAT' if 'X' in t['marks'] else 'DAILY')
                    trips.append({
                        'trip_id': trip_id, 'route_id': LINE, 'train_number': t['number'],
                        'direction': 'down' if src['direction'] == 'down' else 'up',
                        'service_days': days, 'train_type': 'fast' if skipped else 'slow',
                        'ac': 'AC' in t['marks'], 'ladies_special': False,
                        'valid_from': src['valid_from'], 'source_id': MANIFEST['source_id'],
                        'origin_name': fixed[0][0], 'headsign': fixed[-1][0],
                    })
                    for seq, (sid, m) in enumerate(pack_stops, 1):
                        stop_times.append([trip_id, seq, sid, None, f'{m // 60:02d}:{m % 60:02d}'])
    return trips, stop_times


if __name__ == '__main__':
    trips, stop_times = build()
    out = os.path.join(DIR, 'cr_main_timetable.json')
    with open(out, 'w', encoding='utf-8') as f:
        json.dump({'source_id': MANIFEST['source_id'], 'trips': trips, 'stop_times': stop_times},
                  f, ensure_ascii=False, separators=(',', ':'))
    print(f'{len(trips)} trains, {len(stop_times)} stop times -> {os.path.relpath(out, ROOT)}')
