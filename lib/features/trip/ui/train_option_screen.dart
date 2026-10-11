import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/data_source_label.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/source_badge.dart';
import '../../lastmile/data/lastmile_providers.dart';
import '../../lastmile/domain/lastmile_engine.dart';
import '../../lastmile/domain/lastmile_models.dart';
import '../../transit/data/transit_providers.dart';
import '../../transit/domain/models.dart';
import '../../transit/domain/timetable.dart';
import '../../transit/ui/journey_card.dart';
import '../domain/trip_options.dart';
import '../domain/trip_planner.dart';
import 'nearby_transport_screen.dart';
import 'trip_option_tile.dart';
import 'where_is_my_train_screen.dart';

/// The train option in full: each step, and the trains you can catch.
class TrainOptionScreen extends ConsumerStatefulWidget {
  const TrainOptionScreen({super.key, required this.plan, required this.option});

  final TripPlan plan;
  final TripOption option;

  @override
  ConsumerState<TrainOptionScreen> createState() => _TrainOptionState();
}

class _TrainOptionState extends ConsumerState<TrainOptionScreen> {
  String? _boardId;
  String? _alightId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pack = ref.watch(dataPackProvider).value!.pack;
    final tt = ref.watch(timetableProvider);
    final now = ref.watch(clockProvider)();
    var plan = widget.plan;
    var option = widget.option;
    if (_boardId != null || _alightId != null) {
      final re = TripPlanner(pack, ref.watch(routePlannerProvider)!,
              ref.watch(lastMileEngineProvider)!)
          .plan(plan.from, plan.to, now, boardId: _boardId, alightId: _alightId);
      final o = buildTripOptions(re, pack, tt, now)
          .where((o) => o.kind == TripOptionKind.train)
          .firstOrNull;
      if (re.hasTrain && o != null) {
        plan = re;
        option = o;
      }
    }
    final text = Theme.of(context).textTheme;
    final ride = plan.rail!.rides.first;
    String name(String id) => pack.stationById[id]?.name(lang) ?? id;
    final board = name(ride.fromId), alight = name(ride.toId);

    final runs = tt != null && pack.hasTimetable
        ? tt.runsBetween(ride.fromId, ride.toId, now,
            afterMinute: now.hour * 60 + now.minute - 2, limit: 12)
        : const <TrainRun>[];

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
          const SizedBox(height: 4),
          Text(optionFare(l, option), style: text.titleSmall),
          const SizedBox(height: 16),
          if (plan.firstMile?.result != null)
            _RoadStep(
              mode: option.firstLeg,
              title: option.firstLeg == LegMode.walk
                  ? l.stepWalkTo(board)
                  : l.stepAutoTo(board),
              result: plan.firstMile!.result!,
              onWhere: () => _whereAuto(context, plan.from.point, plan.from.name),
            ),
          if (plan.boardChoices.length > 1)
            _StationChoice(
              label: l.boardAtLabel,
              choices: plan.boardChoices,
              selectedId: ride.fromId,
              onSelected: (id) => setState(() => _boardId = id),
            ),
          JourneyCard(journey: plan.rail!, pack: pack),
          if (plan.lastMile?.result != null)
            _RoadStep(
              mode: option.lastLeg,
              title: option.lastLeg == LegMode.walk
                  ? l.stepWalkTo(plan.to.name)
                  : l.stepAutoTo(plan.to.name),
              result: plan.lastMile!.result!,
              onWhere: () {
                final s = plan.lastMile!.station;
                _whereAuto(context, GeoPoint(s.lat, s.lng), s.name(lang));
              },
            ),
          if (plan.alightChoices.length > 1)
            _StationChoice(
              label: l.getOffAtLabel,
              choices: plan.alightChoices,
              selectedId: ride.toId,
              onSelected: (id) => setState(() => _alightId = id),
            ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: Text(l.trainsBetween(board, alight),
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SourceBadge(kind: DataSourceKind.scheduled),
          ]),
          const SizedBox(height: 8),
          if (!pack.hasTimetable)
            _NoTimetable(board: board, alight: alight)
          else if (runs.isEmpty)
            Text(l.noMoreTrainsToday)
          else
            for (final r in runs)
              _RunTile(
                run: r,
                pack: pack,
                now: now,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => WhereIsMyTrainScreen(run: r, pack: pack),
                )),
              ),
        ],
      ),
    );
  }

  void _whereAuto(BuildContext context, GeoPoint point, String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => NearbyTransportScreen(
            mode: NearbyMode.auto, point: point, placeName: name),
      ));
}

/// Lets the user pick another nearby station, e.g. Thane instead of Kalwa.
class _StationChoice extends StatelessWidget {
  const _StationChoice({
    required this.label,
    required this.choices,
    required this.selectedId,
    required this.onSelected,
  });

  final String label;
  final List<Station> choices;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          for (final s in choices)
            ChoiceChip(
              key: Key('station-${s.id}'),
              label: Text(s.name(lang)),
              selected: s.id == selectedId,
              onSelected: (_) => onSelected(s.id),
            ),
        ],
      ),
    );
  }
}

class _RoadStep extends StatelessWidget {
  const _RoadStep({
    required this.mode,
    required this.title,
    required this.result,
    required this.onWhere,
  });

  final LegMode mode;
  final String title;
  final LastMileResult result;
  final VoidCallback onWhere;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final walk = result.options.where((o) => o.kind == OptionKind.walk).firstOrNull;
    final auto =
        result.options.where((o) => o.kind == OptionKind.autoMeter).firstOrNull;
    final isWalk = mode == LegMode.walk;
    final chosen = isWalk ? walk : auto;
    final details = [
      l.distanceRoadEstimate(result.km.toStringAsFixed(1)),
      if (chosen?.minutes != null) l.minutesShort(chosen!.minutes!),
      if (!isWalk && auto?.fare != null)
        auto!.fare!.minimumOnly
            ? l.fareFrom(auto.fare!.amount)
            : l.fareAbout(auto.fare!.amount),
    ].join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(isWalk ? Icons.directions_walk : Icons.electric_rickshaw,
              color: isWalk ? AppColors.walk : AppColors.auto, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                Text(details, style: text.bodySmall),
              ],
            ),
          ),
          if (!isWalk)
            TextButton(onPressed: onWhere, child: Text(l.whereIsMyAuto)),
        ]),
      ),
    );
  }
}

class _NoTimetable extends StatelessWidget {
  const _NoTimetable({required this.board, required this.alight});
  final String board;
  final String alight;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(Icons.schedule, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Text(l.timetableComingFor(board, alight))),
        ]),
      ),
    );
  }
}

class _RunTile extends StatelessWidget {
  const _RunTile({
    required this.run,
    required this.pack,
    required this.now,
    required this.onTap,
  });

  final TrainRun run;
  final DataPack pack;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final inMin = run.departure - (now.hour * 60 + now.minute);
    final fast = run.trip.trainType == 'fast';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatMinutes(run.departure),
                    style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(inMin <= 0 ? l.departingNow : l.inMinutes(inMin),
                    style: text.labelMedium?.copyWith(
                        color: inMin <= 5 ? AppColors.bus : null)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.towards(pack.stationById[run.terminusId]?.name(lang) ??
                        run.terminusId),
                    style: text.titleSmall,
                  ),
                  Text([
                    fast ? l.fastTrain : l.slowTrain,
                    if (run.trip.ac) l.acTrain,
                    if (run.trip.ladiesSpecial) l.ladiesTrain,
                    l.reachesAt(formatMinutes(run.arrival)),
                  ].join(' · '), style: text.bodySmall),
                ],
              ),
            ),
            Column(children: [
              const Icon(Icons.gps_fixed, color: AppColors.localTrain),
              Text(l.whereShort, style: text.labelSmall),
            ]),
          ]),
        ),
      ),
    );
  }
}
