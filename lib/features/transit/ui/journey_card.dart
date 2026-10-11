import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/data_source_label.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/source_badge.dart';
import '../data/transit_providers.dart';
import '../domain/models.dart';
import '../domain/route_planner.dart';
import '../domain/timetable.dart';
import 'line_badge.dart';

class JourneyCard extends ConsumerWidget {
  const JourneyCard({super.key, required this.journey, required this.pack});

  final Journey journey;
  final DataPack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final tt = ref.watch(timetableProvider);
    final now = DateTime.now();
    final scheduled = (tt != null && pack.hasTimetable)
        ? tt.schedule(journey, now, now.hour * 60 + now.minute)
        : null;
    String name(String id) => pack.stationById[id]?.name(lang) ?? id;

    final children = <Widget>[];
    var rideIndex = 0;
    for (final leg in journey.legs) {
      switch (leg) {
        case WalkLeg():
          children.add(ListTile(
            leading: const Icon(Icons.directions_walk),
            title: Text(l.walkTo(name(leg.toId), leg.minutes)),
            subtitle: const Align(
              alignment: Alignment.centerLeft,
              child: SourceBadge(kind: DataSourceKind.estimate),
            ),
          ));
        case RideLeg():
          final s = scheduled?[rideIndex];
          rideIndex++;
          children.add(_RideTile(leg: leg, scheduled: s, name: name));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...children,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                !pack.hasTimetable
                    ? l.timetableNotLoaded
                    : scheduled == null
                        ? l.noMoreTrainsToday
                        : '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile({required this.leg, required this.scheduled, required this.name});

  final RideLeg leg;
  final ScheduledLeg? scheduled;
  final String Function(String) name;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 72,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              color: lineColor(leg.line),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LineBadge(line: leg.line),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => context.push('/station/${leg.fromId}'),
                  child: Text(l.boardAt(name(leg.fromId)), style: text.bodyLarge),
                ),
                Text(l.stopsCount(leg.stops), style: text.bodySmall),
                Text(l.alightAt(name(leg.toId)), style: text.bodyLarge),
                if (scheduled != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const SourceBadge(kind: DataSourceKind.scheduled),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.nextTrain(formatMinutes(scheduled!.departure),
                            formatMinutes(scheduled!.arrival)),
                        style: text.bodyMedium,
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
