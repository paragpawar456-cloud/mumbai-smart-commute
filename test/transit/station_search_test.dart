import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mumbai_smart_commute/features/transit/data/transit_providers.dart';
import 'package:mumbai_smart_commute/features/transit/domain/models.dart';

void main() {
  final pack = DataPack.fromJson(
      jsonDecode(File('assets/data/seed_pack.json').readAsStringSync())
          as Map<String, dynamic>);

  test('finds by English prefix, code, Marathi and Hindi', () {
    expect(searchStations(pack, 'kaly').first.id, 'KYN');
    expect(searchStations(pack, 'tna').first.id, 'TNA');
    expect(searchStations(pack, 'कल्याण').first.id, 'KYN');
    expect(searchStations(pack, 'ठाणे').first.id, 'TNA');
  });

  test('Ghatkopar returns both the suburban and metro stations', () {
    final ids = searchStations(pack, 'ghatkopar').map((s) => s.id);
    expect(ids, containsAll(['GC', 'M1-GKP']));
  });

  test('empty query returns nothing', () {
    expect(searchStations(pack, '  '), isEmpty);
  });
}
