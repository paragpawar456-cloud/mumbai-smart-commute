import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../lastmile/domain/lastmile_engine.dart';
import '../../lastmile/ui/option_card.dart';
import '../domain/trip_options.dart';
import '../domain/trip_planner.dart';
import 'nearby_transport_screen.dart';
import 'trip_option_tile.dart';

/// A road option (auto, cab, bus or walk) in full.
class RoadOptionScreen extends StatelessWidget {
  const RoadOptionScreen({super.key, required this.plan, required this.option});

  final TripPlan plan;
  final TripOption option;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final where = switch (option.kind) {
      TripOptionKind.auto || TripOptionKind.cab => NearbyMode.auto,
      TripOptionKind.bus => NearbyMode.bus,
      _ => null,
    };
    return Scaffold(
      appBar: AppBar(title: Text(optionTitle(l, option))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            ModeChain(option: option),
            const Spacer(),
            if (option.minutes != null)
              Text(l.minutesBig(option.minutes!),
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          DistanceLine(result: plan.direct, road: null),
          const SizedBox(height: 12),
          if (where != null)
            FilledButton.icon(
              key: const Key('whereButton'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => NearbyTransportScreen(
                  mode: where,
                  point: plan.from.point,
                  placeName: plan.from.name,
                  destination: plan.to.point,
                  destinationName: plan.to.name,
                ),
              )),
              icon: const Icon(Icons.gps_fixed),
              label: Text(where == NearbyMode.auto ? l.whereIsMyAuto : l.whereIsMyBus),
            ),
          const SizedBox(height: 12),
          for (final o in LastMileEngine.sort(option.roadOptions, SortBy.cheapest))
            LastMileOptionCard(option: o),
          const SizedBox(height: 8),
          Text(l.assumptionsBody, style: text.bodySmall),
        ],
      ),
    );
  }
}
