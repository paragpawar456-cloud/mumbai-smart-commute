import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/data_source_label.dart';
import '../../../core/providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../alerts/alerts.dart';
import '../../../shared/widgets/info_state.dart';
import '../../../shared/widgets/source_badge.dart';
import '../../../shared/widgets/timetable_note.dart';
import '../data/transit_providers.dart';
import '../../trip/ui/where_is_my_train_screen.dart';
import '../domain/models.dart';
import '../domain/timetable.dart';
import 'line_badge.dart';

class StationScreen extends ConsumerWidget {
  const StationScreen({super.key, required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pack = ref.watch(dataPackProvider).value?.pack;
    final station = pack?.stationById[stationId];
    if (pack == null || station == null) {
      return Scaffold(
        appBar: AppBar(),
        body: InfoState(icon: Icons.help_outline, message: l.noStationFound),
      );
    }
    final lines = pack.lines.where((ln) => ln.stationIds.contains(stationId));
    final tt = ref.watch(timetableProvider);
    final now = ref.watch(clockProvider)();
    final departures = pack.hasTimetable && tt != null
        ? tt.departuresFrom(stationId, now, afterMinute: now.hour * 60 + now.minute)
        : const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(station.name(lang)),
        actions: [
          IconButton(
            key: const Key('lastMileFromStation'),
            tooltip: l.lastMileFromHere,
            icon: const Icon(Icons.electric_rickshaw),
            onPressed: () => context.push('/last-mile?from=$stationId'),
          ),
          IconButton(
            tooltip: l.showOnMap,
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.go('/map?station=$stationId'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AlertBanners(where: (a) => a.appliesToStation(pack, stationId)),
          Text(l.linesAtStation, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final ln in lines) LineBadge(line: ln),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: Text(l.departures,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SourceBadge(kind: DataSourceKind.scheduled),
          ]),
          const SizedBox(height: 8),
          if (!pack.hasTimetable)
            Text(l.timetableNotLoaded)
          else if (departures.isEmpty)
            Text(l.noMoreTrainsToday)
          else ...[
            TimetableNote(validFrom: departures.first.trip.validFrom),
            for (final d in departures)
              ListTile(
                contentPadding: EdgeInsets.zero,
                trailing: const Icon(Icons.gps_fixed),
                onTap: () {
                  final stops = tt!.stopsOf(d.trip.id);
                  final i = stops.indexWhere(
                      (s) => s.stationId == stationId && s.departure == d.departure);
                  if (i == -1) return;
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => WhereIsMyTrainScreen(
                        run: TrainRun(d.trip, stops, i, stops.length - 1),
                        pack: pack),
                  ));
                },
                leading: Text(formatMinutes(d.departure),
                    style: Theme.of(context).textTheme.titleLarge),
                title: Text(l.towards(
                    trainHeadsign(d.trip, pack, d.terminusId, lang))),
                subtitle: Text([
                  d.trip.trainType == 'fast' ? l.fastTrain : l.slowTrain,
                  if (d.trip.ac) l.acTrain,
                  if (d.trip.ladiesSpecial) l.ladiesTrain,
                  if (d.platform != null) l.platformShort(d.platform!),
                ].join(' · ')),
              ),
          ],
        ],
      ),
    );
  }
}
