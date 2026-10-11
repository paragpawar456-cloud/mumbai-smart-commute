import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/settings_controller.dart';
import '../domain/lastmile_models.dart';

/// An auto or taxi stand the user added themselves. Kept on this phone only
/// and always labelled "Added by you", never shown as verified data.
class MyStand {
  const MyStand({
    required this.name,
    required this.point,
    required this.taxi,
    required this.addedAt,
  });

  factory MyStand.fromJson(Map<String, dynamic> j) => MyStand(
        name: j['name'] as String,
        point: GeoPoint((j['lat'] as num).toDouble(), (j['lng'] as num).toDouble()),
        taxi: j['taxi'] as bool? ?? false,
        addedAt: DateTime.parse(j['addedAt'] as String),
      );

  final String name;
  final GeoPoint point;
  final bool taxi;
  final DateTime addedAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': point.lat,
        'lng': point.lng,
        'taxi': taxi,
        'addedAt': addedAt.toIso8601String(),
      };
}

const _key = 'lastmile.myStands';

class MyStandsController extends Notifier<List<MyStand>> {
  @override
  List<MyStand> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const [];
    try {
      return [
        for (final j in jsonDecode(raw) as List)
          MyStand.fromJson(j as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(MyStand s) => _save([...state, s]);

  Future<void> remove(MyStand s) =>
      _save([for (final x in state) if (!identical(x, s)) x]);

  Future<void> _save(List<MyStand> list) async {
    state = list;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode([for (final s in list) s.toJson()]));
  }
}

final myStandsProvider =
    NotifierProvider<MyStandsController, List<MyStand>>(MyStandsController.new);
