import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/info_state.dart';
import '../../lastmile/data/lastmile_providers.dart';
import '../../lastmile/domain/lastmile_engine.dart';
import '../../lastmile/ui/option_card.dart';
import '../../transit/data/transit_providers.dart';
import '../../transit/domain/models.dart';
import '../../transit/ui/journey_card.dart';
import '../domain/trip_planner.dart';
import '../domain/trip_point.dart';
import 'location_search.dart';

/// Door to door between any two points: the train with the road legs at each
/// end, and the direct road options, side by side.
class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({super.key, required this.from, required this.to});

  final TripPoint from;
  final TripPoint to;

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  late TripPoint _from = widget.from;
  late TripPoint _to = widget.to;

  Future<void> _change(bool isFrom) async {
    final p = await pickTripPoint(context, ref, allowMyLocation: isFrom);
    if (p != null) setState(() => isFrom ? _from = p : _to = p);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loaded = ref.watch(dataPackProvider);
    final pack = loaded.value?.pack;
    final rail = ref.watch(routePlannerProvider);
    final road = ref.watch(lastMileEngineProvider);
    if (pack == null || rail == null || road == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tripTitle)),
        body: loaded.hasError
            ? InfoState(icon: Icons.error_outline, message: l.errorGeneric)
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final plan = TripPlanner(pack, rail, road).plan(_from, _to, DateTime.now());
    final train = _TrainSection(plan: plan, pack: pack);
    final byRoad = _RoadSection(plan: plan);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.tripTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(children: [
              ListTile(
                key: const Key('tripFrom'),
                leading: const Icon(Icons.trip_origin, color: AppColors.brand),
                title: Text(_from.name),
                subtitle: Text(l.fromLabel),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _change(true),
              ),
              const Divider(height: 1),
              ListTile(
                key: const Key('tripTo'),
                leading: const Icon(Icons.place, color: AppColors.bus),
                title: Text(_to.name),
                subtitle: Text(l.toLabel),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _change(false),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          if (plan.noTrainReason != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                switch (plan.noTrainReason!) {
                  NoTrainReason.close => l.tripRoadOnlyClose,
                  NoTrainReason.sameStation => l.tripRoadOnlyClose,
                  NoTrainReason.noStationNear => l.tripNoStationNear,
                  NoTrainReason.noRoute => l.noRouteFound,
                },
                style: text.bodyMedium,
              ),
            ),
          if (plan.trainFirst) ...[train, const SizedBox(height: 24), byRoad]
          else ...[
            byRoad,
            if (plan.hasTrain) ...[const SizedBox(height: 24), train],
          ],
          const SizedBox(height: 16),
          if (_from.source == TripPointSource.osm ||
              _to.source == TripPointSource.osm)
            Text(l.osmSearchCredit, style: text.bodySmall),
          const SizedBox(height: 4),
          Text(l.assumptionsBody, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.icon, this.title);
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ]),
      );
}

class _RoadSection extends StatelessWidget {
  const _RoadSection({required this.plan});
  final TripPlan plan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      key: const Key('roadSection'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(Icons.local_taxi_outlined, l.tripByRoad),
        DistanceLine(result: plan.direct, road: null),
        const SizedBox(height: 8),
        for (final o in LastMileEngine.sort(plan.direct.options, SortBy.cheapest))
          LastMileOptionCard(option: o),
      ],
    );
  }
}

class _TrainSection extends StatelessWidget {
  const _TrainSection({required this.plan, required this.pack});
  final TripPlan plan;
  final DataPack pack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final first = plan.firstMile!, last = plan.lastMile!;
    return Column(
      key: const Key('trainSection'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(Icons.train, l.tripByTrain),
        if (first.result != null)
          _LegTile(
            title: l.tripLegToStation(first.station.name(lang)),
            result: first.result!,
          ),
        JourneyCard(journey: plan.rail!, pack: pack),
        if (last.result != null)
          _LegTile(
            title: l.tripLegFromStation(last.station.name(lang), plan.to.name),
            result: last.result!,
          ),
      ],
    );
  }
}

/// A road leg to or from a station, collapsed to one line until opened.
class _LegTile extends StatelessWidget {
  const _LegTile({required this.title, required this.result});
  final String title;
  final LastMileResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final km = result.km.toStringAsFixed(1);
    final walk = result.options.where((o) => o.kind == OptionKind.walk).firstOrNull;
    final auto =
        result.options.where((o) => o.kind == OptionKind.autoMeter).firstOrNull;
    final summary = [
      l.distanceRoadEstimate(km),
      if (walk != null) '${l.optWalk} ${l.minutesShort(walk.minutes!)}',
      if (auto?.fare != null)
        '${l.optAutoMeter} ${auto!.fare!.minimumOnly ? l.fareFrom(auto.fare!.amount) : l.fareAbout(auto.fare!.amount)}',
    ].join(' · ');
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.electric_rickshaw, color: AppColors.auto),
        title: Text(title),
        subtitle: Text(summary),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        children: [
          for (final o in LastMileEngine.sort(result.options, SortBy.cheapest))
            LastMileOptionCard(option: o),
        ],
      ),
    );
  }
}
