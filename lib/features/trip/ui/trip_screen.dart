import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/info_state.dart';
import '../../lastmile/data/lastmile_providers.dart';
import '../../transit/data/transit_providers.dart';
import '../domain/trip_options.dart';
import '../domain/trip_planner.dart';
import '../domain/trip_point.dart';
import 'location_search.dart';
import 'road_option_screen.dart';
import 'train_option_screen.dart';
import 'trip_option_tile.dart';

/// Door to door between any two points: every way to go, side by side.
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

  void _open(TripPlan plan, TripOption o) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => o.kind == TripOptionKind.train
          ? TrainOptionScreen(plan: plan, option: o)
          : RoadOptionScreen(plan: plan, option: o),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loaded = ref.watch(dataPackProvider);
    final pack = loaded.value?.pack;
    final rail = ref.watch(routePlannerProvider);
    final road = ref.watch(lastMileEngineProvider);
    final tt = ref.watch(timetableProvider);
    if (pack == null || rail == null || road == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.tripTitle)),
        body: loaded.hasError
            ? InfoState(icon: Icons.error_outline, message: l.errorGeneric)
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final now = ref.watch(clockProvider)();
    final plan = TripPlanner(pack, rail, road).plan(_from, _to, now);
    final options = buildTripOptions(plan, pack, tt, now);
    final fastest = fastestOption(options);
    final cheapest = cheapestOption(options);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.tripTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RouteHeader(
            from: _from,
            to: _to,
            km: plan.direct.km,
            onFrom: () => _change(true),
            onTo: () => _change(false),
          ),
          const SizedBox(height: 20),
          Text(l.waysToGo(options.length),
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          if (plan.noTrainReason != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                switch (plan.noTrainReason!) {
                  NoTrainReason.close || NoTrainReason.sameStation =>
                    l.tripRoadOnlyClose,
                  NoTrainReason.noStationNear => l.tripNoStationNear,
                  NoTrainReason.noRoute => l.noRouteFound,
                },
                style: text.bodyMedium,
              ),
            ),
          const SizedBox(height: 8),
          for (final o in options)
            TripOptionTile(
              key: Key('option-${o.kind.name}'),
              option: o,
              fastest: identical(o, fastest) && options.length > 1,
              cheapest: identical(o, cheapest) && options.length > 1,
              onTap: () => _open(plan, o),
            ),
          const SizedBox(height: 8),
          if (_from.source == TripPointSource.osm ||
              _to.source == TripPointSource.osm)
            Text(l.osmSearchCredit, style: text.bodySmall),
          const SizedBox(height: 4),
          Text(l.optionsTimeNote, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({
    required this.from,
    required this.to,
    required this.km,
    required this.onFrom,
    required this.onTo,
  });

  final TripPoint from;
  final TripPoint to;
  final double km;
  final VoidCallback onFrom;
  final VoidCallback onTo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const white = Colors.white;
    final text = Theme.of(context).textTheme;
    Widget end(Key key, IconData icon, String label, String name, VoidCallback onTap) =>
        InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Icon(icon, color: white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: text.labelSmall?.copyWith(color: white.withValues(alpha: 0.8))),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                            color: white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 18, color: white.withValues(alpha: 0.8)),
            ]),
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.brand, Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          end(const Key('tripFrom'), Icons.trip_origin, l.fromLabel, from.name, onFrom),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Container(width: 2, height: 14, color: white.withValues(alpha: 0.5)),
          ),
          end(const Key('tripTo'), Icons.place, l.toLabel, to.name, onTo),
          const SizedBox(height: 4),
          Text(l.distanceRoadEstimate(km.toStringAsFixed(1)),
              style: text.bodySmall?.copyWith(color: white.withValues(alpha: 0.9))),
        ],
      ),
    );
  }
}
