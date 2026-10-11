import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/data_source_label.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/info_state.dart';
import '../../../shared/widgets/source_badge.dart';
import '../../transit/data/transit_providers.dart';
import '../../transit/domain/models.dart';
import '../../transit/ui/station_picker.dart';
import '../data/lastmile_providers.dart';
import '../domain/lastmile_engine.dart';
import '../domain/lastmile_models.dart';
import 'map_point_picker.dart';
import 'place_search.dart';

/// Station → doorstep: every way to cover the last stretch, with honest
/// labels. Fares are estimates from the official rate card; availability of
/// vehicles is never claimed.
class LastMileScreen extends ConsumerStatefulWidget {
  const LastMileScreen({super.key, this.fromStationId, this.placeId});

  final String? fromStationId;
  final String? placeId;

  @override
  ConsumerState<LastMileScreen> createState() => _LastMileScreenState();
}

class _Destination {
  const _Destination(this.point, {this.place});
  final GeoPoint point;
  final Place? place;
}

class _LastMileScreenState extends ConsumerState<LastMileScreen> {
  String? _stationId;
  _Destination? _dest;
  SortBy _sort = SortBy.cheapest;
  RoadDistance? _road;
  bool _initialised = false;

  void _init(DataPack pack) {
    if (_initialised) return;
    _initialised = true;
    _stationId = pack.stationById.containsKey(widget.fromStationId)
        ? widget.fromStationId
        : (pack.stationById.containsKey('KYN') ? 'KYN' : pack.stations.first.id);
    final place = pack.lastMile.places
        .where((p) => p.id == widget.placeId)
        .firstOrNull;
    if (place != null) _setDest(_Destination(place.point, place: place));
  }

  Station? _station(DataPack pack) => pack.stationById[_stationId];

  void _setDest(_Destination? d) {
    setState(() {
      _dest = d;
      _road = null;
    });
    _fetchRoad();
  }

  Future<void> _fetchRoad() async {
    final pack = ref.read(dataPackProvider).value?.pack;
    final s = pack == null ? null : _station(pack);
    final d = _dest;
    final signedIn = ref.read(authStateProvider).value != null;
    final api = ref.read(lastMileApiProvider);
    if (s == null || d == null || !signedIn || !api.available) return;
    final r = await api.roadDistance(GeoPoint(s.lat, s.lng), d.point);
    if (mounted && identical(d, _dest)) setState(() => _road = r);
  }

  Future<void> _chooseStation(DataPack pack) async {
    final s = await pickStation(context, pack);
    if (s == null) return;
    setState(() => _stationId = s.id);
    _setDest(_dest);
  }

  Future<void> _chooseDest(DataPack pack) async {
    final r = await pickPlace(context, pack.lastMile);
    if (!mounted || r == null) return;
    if (r is Place) {
      _setDest(_Destination(r.point, place: r));
    } else if (r == 'map') {
      final s = _station(pack)!;
      final p = await pickPointOnMap(context, _dest?.point ?? GeoPoint(s.lat, s.lng));
      if (p != null) _setDest(_Destination(p));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loaded = ref.watch(dataPackProvider);
    final pack = loaded.value?.pack;
    if (pack == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.lastMileTitle)),
        body: loaded.hasError
            ? InfoState(icon: Icons.error_outline, message: l.errorGeneric)
            : const Center(child: CircularProgressIndicator()),
      );
    }
    _init(pack);
    final lang = Localizations.localeOf(context).languageCode;
    final station = _station(pack)!;
    final from = GeoPoint(station.lat, station.lng);
    final engine = ref.watch(lastMileEngineProvider)!;
    final result = _dest == null
        ? null
        : engine.plan(from, _dest!.point, DateTime.now(),
            roadKm: _road?.km,
            fromName: station.nameEn,
            toName: _dest!.place?.nameEn ?? '');

    return Scaffold(
      appBar: AppBar(title: Text(l.lastMileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  key: const Key('lastMileFrom'),
                  leading: const Icon(Icons.train, color: AppColors.localTrain),
                  title: Text(station.name(lang)),
                  subtitle: Text(l.lastMileFromStation),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _chooseStation(pack),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('lastMileTo'),
                  leading: const Icon(Icons.place, color: AppColors.bus),
                  title: Text(_dest == null
                      ? l.lastMileToHint
                      : _dest!.place?.name(lang) ?? l.lastMileDroppedPin),
                  subtitle: Text(l.lastMileTo),
                  trailing: const Icon(Icons.search),
                  onTap: () => _chooseDest(pack),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (result == null)
            InfoState(
                icon: Icons.directions_walk, message: l.lastMileChooseDestination)
          else ...[
            _DistanceLine(result: result, road: _road),
            const SizedBox(height: 12),
            SegmentedButton<SortBy>(
              segments: [
                ButtonSegment(value: SortBy.cheapest, label: Text(l.sortCheapest)),
                ButtonSegment(value: SortBy.fastest, label: Text(l.sortFastest)),
                ButtonSegment(
                    value: SortBy.leastWalking, label: Text(l.sortLeastWalking)),
              ],
              selected: {_sort},
              onSelectionChanged: (s) => setState(() => _sort = s.first),
            ),
            const SizedBox(height: 12),
            for (final o in LastMileEngine.sort(result.options, _sort))
              _OptionCard(option: o),
            if (pack.lastMile.fareRules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l.noFareRules),
              ),
            _Assumptions(pack: pack, engine: engine),
          ],
          const SizedBox(height: 16),
          _NearbyStands(pack: pack, from: from),
          const SizedBox(height: 16),
          _CommunityReports(station: station, pack: pack),
        ],
      ),
    );
  }
}

String _km(double km) => km.toStringAsFixed(1);

class _DistanceLine extends StatelessWidget {
  const _DistanceLine({required this.result, required this.road});
  final LastMileResult result;
  final RoadDistance? road;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.kmIsRoad
              ? l.distanceRoad(_km(result.km))
              : l.distanceRoadEstimate(_km(result.km)),
          style: text.titleMedium,
        ),
        Text(
          road != null && road!.attribution.isNotEmpty
              ? '${l.distanceStraight(_km(result.straightKm))} · ${road!.attribution}'
              : l.distanceStraight(_km(result.straightKm)),
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option});
  final LastMileOption option;

  (IconData, Color) get _look => switch (option.kind) {
        OptionKind.walk => (Icons.directions_walk, AppColors.walk),
        OptionKind.autoMeter => (Icons.electric_rickshaw, AppColors.auto),
        OptionKind.sharedAuto => (Icons.groups_outlined, AppColors.auto),
        OptionKind.taxiMeter => (Icons.local_taxi, AppColors.taxi),
        OptionKind.bus => (Icons.directions_bus, AppColors.bus),
        OptionKind.rideHailing => (Icons.phone_android, AppColors.brand),
      };

  Future<void> _open(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(option.bookingUri!,
        mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(l.couldNotOpen)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final (icon, color) = _look;
    final o = option;
    final title = switch (o.kind) {
      OptionKind.walk => l.optWalk,
      OptionKind.autoMeter => l.optAutoMeter,
      OptionKind.taxiMeter => l.optTaxiMeter,
      OptionKind.sharedAuto => '${l.optSharedAuto} · ${o.pickup!.nameEn}',
      OptionKind.bus => l.optBus(o.busRoute!.operator, o.busRoute!.number),
      OptionKind.rideHailing => o.provider!.name,
    };
    final price = switch (o.kind) {
      OptionKind.walk => '₹0',
      OptionKind.rideHailing => l.fareInApp,
      _ when o.fare != null => o.fare!.minimumOnly
          ? l.fareFrom(o.fare!.amount)
          : l.fareAbout(o.fare!.amount),
      _ when o.fixedFare != null => l.fareShared(o.fixedFare!.round()),
      _ => l.fareUnknown,
    };
    final details = <String>[
      if (o.minutes != null) l.minutesAbout(o.minutes!),
      if (o.kind != OptionKind.walk && o.walkMeters > 0)
        l.walkMeters(o.walkMeters.round()),
      if (o.fare?.nightApplied ?? false) l.nightFareApplied,
      if (o.kind == OptionKind.autoMeter || o.kind == OptionKind.taxiMeter)
        o.pickup != null
            ? l.nearestStand(o.pickup!.nameEn, o.walkMeters.round())
            : l.noStandKnown,
      if (o.kind == OptionKind.bus)
        l.busBoardAlight(o.boardStop!.nameEn, o.alightStop!.nameEn),
      if (o.busRoute?.frequencyNote != null) o.busRoute!.frequencyNote!,
      if (o.pickup?.destinations != null) o.pickup!.destinations!,
      if (o.availability == Availability.unknown && o.kind != OptionKind.rideHailing)
        l.availabilityUnknown,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleSmall),
                  const SizedBox(height: 2),
                  for (final d in details) Text(d, style: text.bodySmall),
                  const SizedBox(height: 6),
                  Row(children: [
                    SourceBadge(kind: o.sourceKind),
                    const Spacer(),
                    if (o.bookingUri != null)
                      TextButton.icon(
                        onPressed: () => _open(context),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(l.openApp(o.provider!.name)),
                      ),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(price, style: text.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _Assumptions extends StatelessWidget {
  const _Assumptions({required this.pack, required this.engine});
  final DataPack pack;
  final LastMileEngine engine;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final lines = <String>[l.assumptionsBody];
    for (final mode in ['auto', 'taxi']) {
      final f = engine.meterFare(mode, 0, now);
      if (f == null) continue;
      final src = pack.sources.where((s) => s.id == f.rule.sourceId).firstOrNull;
      lines.add(l.fareRuleSource(
        mode == 'auto' ? l.optAutoMeter : l.optTaxiMeter,
        src?.attribution ?? src?.name ?? f.rule.sourceId,
        DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(f.rule.effectiveFrom),
      ));
    }
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: Text(l.howWeEstimate),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(s),
          ),
      ],
    );
  }
}

class _NearbyStands extends StatelessWidget {
  const _NearbyStands({required this.pack, required this.from});
  final DataPack pack;
  final GeoPoint from;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final near = pack.lastMile.pickupPoints
        .map((p) => (p, distanceMeters(from, p.point)))
        .where((e) => e.$2 <= 1500)
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.nearbyPickups, style: text.titleMedium),
        if (near.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l.nearbyPickupsEmpty),
          ),
        for (final (p, m) in near)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(p.kind == PickupKind.taxiStand
                ? Icons.local_taxi
                : Icons.electric_rickshaw),
            title: Text(p.nameEn),
            subtitle: Text('${l.walkMeters(m.round())} · ${switch (p.verification) {
              Verification.adminVerified => l.verificationAdmin,
              Verification.osm => l.verificationOsm,
              Verification.community => l.verificationCommunity,
            }}'),
          ),
      ],
    );
  }
}

class _CommunityReports extends ConsumerWidget {
  const _CommunityReports({required this.station, required this.pack});
  final Station station;
  final DataPack pack;

  String _typeLabel(AppLocalizations l, String t) => switch (t) {
        'queue' => l.reportTypeQueue,
        'no_vehicles' => l.reportTypeNoVehicles,
        'stand_moved' => l.reportTypeStandMoved,
        'stop_issue' => l.reportTypeStopIssue,
        'closure' => l.reportTypeClosure,
        _ => l.reportTypeDisruption,
      };

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    if (ref.read(authStateProvider).value == null) {
      context.push('/sign-in');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => _ReportSheet(
        station: station,
        pack: pack,
        typeLabel: (t) => _typeLabel(l, t),
      ),
    );
    if (sent == true) {
      messenger.showSnackBar(SnackBar(content: Text(l.reportSent)));
      ref.invalidate(reportsNearProvider(station.id));
    }
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref, String id) async {
    final l = AppLocalizations.of(context);
    if (ref.read(authStateProvider).value == null) {
      context.push('/sign-in');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(lastMileApiProvider).confirm(id);
      ref.invalidate(reportsNearProvider(station.id));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final api = ref.watch(lastMileApiProvider);
    final reports = ref.watch(reportsNearProvider(station.id));
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(l.communityReports, style: text.titleMedium)),
          if (api.available)
            TextButton.icon(
              key: const Key('reportButton'),
              onPressed: () => _report(context, ref),
              icon: const Icon(Icons.campaign_outlined),
              label: Text(l.reportSomething),
            ),
        ]),
        if (!api.available)
          Text(l.communityReportsOffline, style: text.bodySmall)
        else
          reports.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
            error: (_, _) => Text(l.errorGeneric, style: text.bodySmall),
            data: (list) => list.isEmpty
                ? Text(l.communityReportsEmpty, style: text.bodySmall)
                : Column(children: [
                    for (final r in list)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const SourceBadge(kind: DataSourceKind.community),
                        title: Text(_typeLabel(l, r.type)),
                        subtitle: Text([
                          l.reportAgo(now.difference(r.createdAt).inMinutes.clamp(0, 99999)),
                          if (r.corroborations > 0) l.reportConfirmed(r.corroborations),
                          if (r.note.isNotEmpty) r.note,
                        ].join(' · ')),
                        trailing: TextButton(
                          onPressed: () => _confirm(context, ref, r.id),
                          child: Text(l.reportConfirm),
                        ),
                      ),
                  ]),
          ),
      ],
    );
  }
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({
    required this.station,
    required this.pack,
    required this.typeLabel,
  });
  final Station station;
  final DataPack pack;
  final String Function(String) typeLabel;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  String _type = reportTypes.first;
  String? _targetId;
  final _note = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final s = widget.station;
    final target = widget.pack.lastMile.pickupPoints
        .where((p) => p.id == _targetId)
        .firstOrNull;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(lastMileApiProvider).submit(
            type: _type,
            at: target?.point ?? GeoPoint(s.lat, s.lng),
            targetId: _targetId ?? s.id,
            note: _note.text,
          );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.station;
    final stands = widget.pack.lastMile.pickupPoints
        .where((p) =>
            distanceMeters(GeoPoint(s.lat, s.lng), p.point) <= 1500)
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reportSomething, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final t in reportTypes)
                ChoiceChip(
                  label: Text(widget.typeLabel(t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          if (stands.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _targetId,
              decoration: InputDecoration(labelText: l.reportWhere),
              items: [
                DropdownMenuItem(value: null, child: Text(s.nameEn)),
                for (final p in stands)
                  DropdownMenuItem(value: p.id, child: Text(p.nameEn)),
              ],
              onChanged: (v) => setState(() => _targetId = v),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLength: 200,
            decoration: InputDecoration(labelText: l.reportNoteHint),
          ),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 8),
          Text(l.reportPrivacy, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: Text(l.reportSubmit),
          ),
        ],
      ),
    );
  }
}
