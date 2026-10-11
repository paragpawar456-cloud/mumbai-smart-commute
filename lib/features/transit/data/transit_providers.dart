import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/models.dart';
import '../domain/route_planner.dart';
import '../domain/timetable.dart';
import 'data_pack_repository.dart';

final dataPackRepositoryProvider = Provider<DataPackRepository>(
  (ref) => DataPackRepository(api: ref.watch(apiClientProvider)),
);

/// Loads the local pack immediately, then quietly checks the server.
class DataPackController extends AsyncNotifier<LoadedPack> {
  @override
  Future<LoadedPack> build() async {
    final repo = ref.watch(dataPackRepositoryProvider);
    final local = await repo.loadLocal();
    Future.microtask(() => refresh());
    return local;
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    final next = await ref.read(dataPackRepositoryProvider).refresh(current);
    if (!identical(next, current)) state = AsyncData(next);
  }
}

final dataPackProvider =
    AsyncNotifierProvider<DataPackController, LoadedPack>(DataPackController.new);

final routePlannerProvider = Provider<RoutePlanner?>((ref) {
  final pack = ref.watch(dataPackProvider).value?.pack;
  return pack == null ? null : RoutePlanner(pack);
});

final timetableProvider = Provider<Timetable?>((ref) {
  final pack = ref.watch(dataPackProvider).value?.pack;
  return pack == null ? null : Timetable(pack);
});

/// Accent- and case-insensitive search across English, Marathi and Hindi names.
List<Station> searchStations(DataPack pack, String query, {int limit = 8}) {
  final q = _norm(query);
  if (q.isEmpty) return const [];
  final scored = <(int, Station)>[];
  for (final s in pack.stations) {
    var best = 99;
    for (final n in [s.nameEn, s.nameMr, s.nameHi, s.id]) {
      if (n == null) continue;
      final v = _norm(n);
      if (v == q) {
        best = 0;
      } else if (v.startsWith(q)) {
        best = best < 1 ? best : 1;
      } else if (v.split(' ').any((w) => w.startsWith(q))) {
        best = best < 2 ? best : 2;
      } else if (v.contains(q)) {
        best = best < 3 ? best : 3;
      }
    }
    if (best < 99) scored.add((best, s));
  }
  scored.sort((a, b) {
    final c = a.$1.compareTo(b.$1);
    return c != 0 ? c : a.$2.nameEn.compareTo(b.$2.nameEn);
  });
  return scored.take(limit).map((e) => e.$2).toList();
}

/// Lower-cased, punctuation-free form used for name search.
String normalizeSearch(String s) => _norm(s);

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{M}\p{N} ]', unicode: true), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
