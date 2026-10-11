// Renders the main screens to PNGs for design review (not part of CI).
//   flutter test tool/screenshots/screens_test.dart --update-goldens
// PNGs land in tool/screenshots/out/.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mumbai_smart_commute/features/trip/data/geocoder.dart';

import '../../test/helpers.dart';

const _manpada = {
  'type': 'FeatureCollection',
  'features': [
    {
      'type': 'Feature',
      'geometry': {'type': 'Point', 'coordinates': [72.9744, 19.2346]},
      'properties': {
        'name': 'Runwal Garden City',
        'district': 'Manpada',
        'city': 'Thane',
        'osm_key': 'place',
      },
    },
  ],
};

Future<void> _loadFonts() async {
  final dir = '${Platform.environment['FLUTTER_ROOT'] ?? '/home/claude/sdk/flutter'}'
      '/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold', 'Light', 'Black']) {
    roboto.addFont(Future.value(
        ByteData.sublistView(File('$dir/Roboto-$w.ttf').readAsBytesSync())));
  }
  await roboto.load();
  final poppins = FontLoader('Poppins');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    poppins.addFont(Future.value(ByteData.sublistView(
        File('assets/fonts/Poppins-$w.ttf').readAsBytesSync())));
  }
  await poppins.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(
        File('$dir/MaterialIcons-Regular.otf').readAsBytesSync())));
  await icons.load();
}

Future<void> _settle(WidgetTester t, [int steps = 8]) async {
  for (var i = 0; i < steps; i++) {
    await t.pump(const Duration(milliseconds: 150));
  }
}

Future<void> _shot(WidgetTester t, String name) async {
  await expectLater(find.byType(MaterialApp).first,
      matchesGoldenFile('out/$name.png'));
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('screens', (t) async {
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 2.625;
    addTearDown(t.view.reset);
    final geocoder = Geocoder(
      baseUrl: 'https://photon.example/api/',
      userAgent: 'test',
      client: MockClient(
          (_) async => http.Response.bytes(utf8.encode(jsonEncode(_manpada)), 200)),
    );
    await t.pumpWidget(await buildTestApp(
      prefs: {'settings.locale': 'en', 'settings.reducedMotion': true},
      overrides: [geocoderProvider.overrideWithValue(geocoder)],
    ));
    await _settle(t);
    await _shot(t, '01_home');
    await t.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await _settle(t);
    await _shot(t, '01b_home_scrolled');
    await t.drag(find.byType(Scrollable).first, const Offset(0, 700));
    await _settle(t);

    await t.tap(find.byKey(const Key('fromField')));
    await _settle(t);
    await t.enterText(find.byType(TextField).last, 'yogidham');
    await _settle(t);
    await t.tap(find.widgetWithText(ListTile, 'Yogidham').first);
    await _settle(t);
    await t.tap(find.byKey(const Key('toField')));
    await _settle(t);
    await t.enterText(find.byType(TextField).last, 'runwal');
    await t.pump(const Duration(milliseconds: 600));
    await _settle(t);
    await t.tap(find.widgetWithText(ListTile, 'Runwal Garden City').first);
    await _settle(t);
    await _shot(t, '02_home_filled');
    await t.tap(find.byKey(const Key('findRoutesButton')));
    await _settle(t);
    await _shot(t, '03_trip');

    await t.tap(find.byKey(const Key('option-train')));
    await _settle(t);
    await _shot(t, '04_train_option');
    await t.scrollUntilVisible(find.byKey(const Key('timetableNote')), 300,
        scrollable: find.byType(Scrollable).first);
    await _settle(t);
    await _shot(t, '05_train_list');
    final run = find.byKey(const Key('runTile'));
    if (run.evaluate().isNotEmpty) {
      await t.tap(run.first);
      await _settle(t);
      await _shot(t, '06_where_is_my_train');
      await t.pageBack();
      await _settle(t);
    }
    await t.pageBack();
    await _settle(t);
    final auto = find.byKey(const Key('option-auto'));
    await t.scrollUntilVisible(auto, -300, scrollable: find.byType(Scrollable).first);
    await t.tap(auto);
    await _settle(t);
    await _shot(t, '07_auto_option');
    await t.tap(find.byKey(const Key('whereButton')));
    await _settle(t);
    await _shot(t, '08_where_is_my_auto');
  });
}
