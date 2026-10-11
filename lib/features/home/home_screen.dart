import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/build_info.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/source_badge.dart';
import '../../shared/widgets/train_tag.dart';
import '../../core/data/data_source_label.dart';
import '../alerts/alerts.dart';
import '../saved/saved_journeys_list.dart';
import '../settings/settings_controller.dart';
import '../transit/data/transit_providers.dart';
import '../transit/domain/models.dart';
import '../transit/domain/timetable.dart';
import '../transit/ui/station_picker.dart';
import '../trip/domain/trip_point.dart';
import '../trip/ui/location_search.dart';
import '../trip/ui/nearby_transport_screen.dart';
import '../trip/ui/where_is_my_train_screen.dart';

/// Station whose next trains Home shows; the user can change it.
const _homeStationKey = 'home.stationId';
const _defaultHomeStation = 'KYN';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TripPoint? _from;
  TripPoint? _to;

  void _swap() => setState(() {
        final f = _from;
        _from = _to;
        _to = f;
      });

  Future<TripPoint?> _pick(bool isFrom) async {
    final p = await pickTripPoint(context, ref, allowMyLocation: isFrom);
    if (p != null) setState(() => isFrom ? _from = p : _to = p);
    return p;
  }

  Future<void> _search() async {
    if (_from == null && await _pick(true) == null) return;
    if (_to == null && await _pick(false) == null) return;
    if (!mounted) return;
    final from = _from!, to = _to!;
    if (from.isStation && to.isStation) {
      context.go(Uri(path: '/routes', queryParameters: {
        'fromId': from.stationId!,
        'toId': to.stationId!,
      }).toString());
    } else {
      context.push(Uri(path: '/trip', queryParameters: {
        ...from.toQuery('from'),
        ...to.toQuery('to'),
      }).toString());
    }
  }

  Future<void> _whereTrain() async {
    final pack = ref.read(dataPackProvider).value?.pack;
    if (pack == null) return;
    final s = await pickStation(context, pack);
    if (s != null && mounted) context.push('/station/${s.id}');
  }

  Future<void> _whereNearby(NearbyMode mode) async {
    final p = await pickTripPoint(context, ref, allowMyLocation: true);
    if (p == null || !mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          NearbyTransportScreen(mode: mode, point: p.point, placeName: p.name),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;
    const headerHeight = 230.0;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(children: [
            Container(
              height: headerHeight + top,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
            ),
            // Faint train icon as a watermark, purely decorative.
            Positioned(
              right: -24,
              top: top + 8,
              child: Icon(Icons.train_rounded,
                  size: 170, color: Colors.white.withValues(alpha: 0.05)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_transit_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(l.appTitle,
                        style: text.titleMedium?.copyWith(color: Colors.white)),
                  ]),
                  const SizedBox(height: 22),
                  Text(l.homeGreeting,
                      style: text.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(l.homeSubtitle,
                      style: text.bodyMedium
                          ?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 20),
                  _SearchCard(
                    from: _from,
                    to: _to,
                    onPickFrom: () => _pick(true),
                    onPickTo: () => _pick(false),
                    onSwap: _swap,
                    onSearch: _search,
                  ),
                ],
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AlertBanners(),
                _SectionTitle(l.trackTitle),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _WhereTile(
                      key: const Key('whereTrain'),
                      icon: Icons.train_rounded,
                      color: AppColors.localTrain,
                      label: l.whereIsMyTrain,
                      onTap: _whereTrain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WhereTile(
                      key: const Key('whereAuto'),
                      icon: Icons.electric_rickshaw_rounded,
                      color: AppColors.auto,
                      label: l.whereIsMyAuto,
                      onTap: () => _whereNearby(NearbyMode.auto),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WhereTile(
                      key: const Key('whereBus'),
                      icon: Icons.directions_bus_rounded,
                      color: AppColors.bus,
                      label: l.whereIsMyBus,
                      onTap: () => _whereNearby(NearbyMode.bus),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WhereTile(
                      key: const Key('whereCab'),
                      icon: Icons.local_taxi_rounded,
                      color: AppColors.taxi,
                      label: l.whereIsMyCab,
                      onTap: () => _whereNearby(NearbyMode.cab),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                const _NextTrainsCard(),
                const SizedBox(height: 24),
                _SectionTitle(l.exploreTitle),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ExploreCard(
                          key: const Key('lastMileCard'),
                          icon: Icons.electric_rickshaw_rounded,
                          color: AppColors.auto,
                          title: l.lastMileTitle,
                          body: l.lastMileHomeBody,
                          onTap: () => context.push('/last-mile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ExploreCard(
                          icon: Icons.near_me_rounded,
                          color: AppColors.brand,
                          title: l.nearbyTransport,
                          body: l.nearbyTransportBody,
                          onTap: () => context.go('/map'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(l.savedJourneys),
                const SizedBox(height: 8),
                const SavedJourneysList(limit: 3),
                const SizedBox(height: 24),
                Center(
                  child: Text(BuildInfo.label(l),
                      key: const Key('buildLabel'),
                      style: text.labelSmall?.copyWith(color: scheme.outline)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        ?trailing,
      ]);
}

/// The From / To card on the header, styled like a map app's route box.
class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
    required this.onSearch,
  });

  final TripPoint? from;
  final TripPoint? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
        child: Column(children: [
          Row(children: [
            // Route dots joined by a dashed line.
            Column(children: [
              Icon(Icons.radio_button_checked, size: 18, color: scheme.primary),
              for (var i = 0; i < 4; i++)
                Container(
                  width: 2,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: scheme.outlineVariant,
                ),
              const Icon(Icons.location_on, size: 20, color: AppColors.bus),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(children: [
                _PointField(
                  key: const Key('fromField'),
                  label: l.fromLabel,
                  hint: l.fromHint,
                  value: from,
                  onTap: onPickFrom,
                ),
                const Divider(height: 12),
                _PointField(
                  key: const Key('toField'),
                  label: l.toLabel,
                  hint: l.toHint,
                  value: to,
                  onTap: onPickTo,
                ),
              ]),
            ),
            IconButton.filledTonal(
              tooltip: '${l.fromLabel} ⇄ ${l.toLabel}',
              onPressed: onSwap,
              icon: const Icon(Icons.swap_vert_rounded),
            ),
          ]),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              key: const Key('findRoutesButton'),
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
              label: Text(l.findRoutes),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Looks like a text line; tapping it opens the place search.
class _PointField extends StatelessWidget {
  const _PointField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final TripPoint? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(
                value?.name ?? hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: value == null
                    ? text.bodyLarge?.copyWith(color: scheme.outline)
                    : text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhereTile extends StatelessWidget {
  const _WhereTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 12),
            child: Column(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600, height: 1.2)),
            ]),
          ),
        ),
      );
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded,
                    size: 20, color: Theme.of(context).colorScheme.outline),
              ]),
              const SizedBox(height: 12),
              Text(title, style: text.titleSmall),
              const SizedBox(height: 4),
              Text(body,
                  style: text.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next few trains from the user's station, counting down, from the official
/// timetable. Hidden when no timetable is loaded.
class _NextTrainsCard extends ConsumerStatefulWidget {
  const _NextTrainsCard();

  @override
  ConsumerState<_NextTrainsCard> createState() => _NextTrainsCardState();
}

class _NextTrainsCardState extends ConsumerState<_NextTrainsCard> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final pack = ref.watch(dataPackProvider).value?.pack;
    final tt = ref.watch(timetableProvider);
    if (pack == null || tt == null || !pack.hasTimetable) {
      return const SizedBox.shrink();
    }
    final prefs = ref.watch(sharedPreferencesProvider);
    var stationId = prefs.getString(_homeStationKey) ?? _defaultHomeStation;
    if (!pack.stationById.containsKey(stationId)) stationId = _defaultHomeStation;
    final station = pack.stationById[stationId];
    if (station == null) return const SizedBox.shrink();
    final now = ref.watch(clockProvider)();
    final minute = now.hour * 60 + now.minute;
    final departures =
        tt.departuresFrom(stationId, now, afterMinute: minute, limit: 4);

    Future<void> change() async {
      final s = await pickStation(context, pack);
      if (s == null) return;
      await prefs.setString(_homeStationKey, s.id);
      if (mounted) setState(() {});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          l.nextTrainsFrom(station.name(lang)),
          trailing: TextButton.icon(
            key: const Key('changeHomeStation'),
            onPressed: change,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: Text(l.change),
          ),
        ),
        const SizedBox(height: 6),
        Card(
          key: const Key('nextTrainsCard'),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            if (departures.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.noMoreTrainsToday),
              ),
            for (final (i, d) in departures.indexed) ...[
              if (i > 0) const Divider(indent: 16, endIndent: 16),
              _NextTrainRow(
                departure: d,
                stationNameEn: station.nameEn,
                pack: pack,
                minutesAway: d.departure - minute,
                onTap: () {
                  final stops = tt.stopsOf(d.trip.id);
                  final at = stops.indexWhere((s) =>
                      s.stationId == stationId && s.departure == d.departure);
                  if (at == -1) return;
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => WhereIsMyTrainScreen(
                        run: TrainRun(d.trip, stops, at, stops.length - 1),
                        pack: pack),
                  ));
                },
              ),
            ],
            Container(
              color: scheme.surfaceContainerLow,
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(children: [
                const SourceBadge(kind: DataSourceKind.scheduled),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.checkStationDisplay,
                      style: text.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                TextButton(
                  onPressed: () => context.push('/station/$stationId'),
                  child: Text(l.allTrains),
                ),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}

class _NextTrainRow extends StatelessWidget {
  const _NextTrainRow({
    required this.departure,
    required this.stationNameEn,
    required this.pack,
    required this.minutesAway,
    required this.onTap,
  });

  final Departure departure;
  final String stationNameEn;
  final DataPack pack;
  final int minutesAway;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final d = departure;
    final fast = d.trip.trainType == 'fast';
    final soon = minutesAway <= 5;
    final origin = trainOrigin(d.trip, stationNameEn);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatMinutes(d.departure),
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  minutesAway <= 0 ? l.departingNow : l.inMinutes(minutesAway),
                  style: text.labelSmall?.copyWith(
                    color: soon ? AppColors.bus : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.towards(trainHeadsign(d.trip, pack, d.terminusId, lang)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall),
                const SizedBox(height: 4),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (origin != null)
                    Text(l.fromPlace(origin),
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  TrainTag(
                    label: fast ? l.fastTrain : l.slowTrain,
                    color: fast ? AppColors.taxi : AppColors.localTrain,
                  ),
                  if (d.trip.ac) TrainTag(label: l.acTrain, color: AppColors.metro),
                  if (d.trip.ladiesSpecial)
                    TrainTag(label: l.ladiesTrain, color: AppColors.bus),
                ]),
              ],
            ),
          ),
          Icon(Icons.gps_fixed_rounded, color: scheme.primary, size: 20),
        ]),
      ),
    );
  }
}
