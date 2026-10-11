import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import 'option_card.dart';
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
            DistanceLine(result: result, road: _road),
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
              LastMileOptionCard(option: o),
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
    // No server in this build: leave the section out rather than show a gap.
    if (!api.available) return const SizedBox.shrink();
    final accounts = ref.watch(accountsEnabledProvider);
    final reports = ref.watch(reportsNearProvider(station.id));
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(l.communityReports, style: text.titleMedium)),
          if (accounts)
            TextButton.icon(
              key: const Key('reportButton'),
              onPressed: () => _report(context, ref),
              icon: const Icon(Icons.campaign_outlined),
              label: Text(l.reportSomething),
            ),
        ]),
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
                        trailing: accounts
                            ? TextButton(
                                onPressed: () => _confirm(context, ref, r.id),
                                child: Text(l.reportConfirm),
                              )
                            : null,
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
