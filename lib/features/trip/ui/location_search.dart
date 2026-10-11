import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../lastmile/data/lastmile_providers.dart';
import '../../lastmile/domain/lastmile_models.dart';
import '../../lastmile/ui/map_point_picker.dart';
import '../../map/location_service.dart';
import '../../map/map_screen.dart' show locationServiceProvider;
import '../../transit/data/transit_providers.dart';
import '../../transit/domain/models.dart';
import '../data/geocoder.dart';
import '../domain/trip_point.dart';

/// Search for any start or destination: stations, the app's own places,
/// OpenStreetMap results, the phone's location or a point on the map.
Future<TripPoint?> pickTripPoint(
  BuildContext context,
  WidgetRef ref, {
  bool allowMyLocation = false,
  String initialQuery = '',
}) async {
  final l = AppLocalizations.of(context);
  final pack = ref.read(dataPackProvider).value?.pack;
  if (pack == null) return null;
  final r = await showSearch<Object?>(
    context: context,
    query: initialQuery,
    delegate: _TripPointSearch(
      pack: pack,
      geocoder: ref.read(geocoderProvider),
      allowMyLocation: allowMyLocation,
      l: l,
    ),
  );
  if (!context.mounted) return null;
  if (r is TripPoint) return r;
  if (r == _myLocation) {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final loc = await ref.read(locationServiceProvider).current();
      if (loc.problem != null) {
        messenger.showSnackBar(SnackBar(
          content: Text(loc.problem == LocationProblem.serviceOff
              ? l.locationServiceOff
              : l.locationDenied),
        ));
        return null;
      }
      return TripPoint(
        name: l.myLocation,
        point: GeoPoint(loc.lat!, loc.lng!),
        source: TripPointSource.myLocation,
      );
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l.errorGeneric)));
      return null;
    }
  }
  if (r == _onMap) {
    final kyn = pack.stationById['KYN'] ?? pack.stations.first;
    final p = await pickPointOnMap(context, GeoPoint(kyn.lat, kyn.lng));
    if (p == null) return null;
    return TripPoint(
        name: l.lastMileDroppedPin, point: p, source: TripPointSource.pin);
  }
  return null;
}

const _myLocation = 'me';
const _onMap = 'map';

TripPoint _fromStation(Station s, String lang) => TripPoint(
      name: s.name(lang),
      point: GeoPoint(s.lat, s.lng),
      source: TripPointSource.station,
      stationId: s.id,
    );

class _TripPointSearch extends SearchDelegate<Object?> {
  _TripPointSearch({
    required this.pack,
    required this.geocoder,
    required this.allowMyLocation,
    required AppLocalizations l,
  }) : super(searchFieldLabel: l.searchAnyPlace);

  final DataPack pack;
  final Geocoder geocoder;
  final bool allowMyLocation;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const BackButtonIcon(),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final q = query.trim();
    final stations = q.isEmpty ? const <Station>[] : searchStations(pack, q, limit: 5);
    final places = q.isEmpty
        ? (pack.lastMile.places.toList()..sort((a, b) => a.nameEn.compareTo(b.nameEn)))
        : searchPlaces(pack.lastMile, q, limit: 5);
    final online = geocoder.isAvailable && q.length >= 3;
    return ListView(
      children: [
        if (allowMyLocation)
          ListTile(
            key: const Key('useMyLocation'),
            leading: const Icon(Icons.my_location, color: AppColors.brand),
            title: Text(l.myLocation),
            onTap: () => close(context, _myLocation),
          ),
        ListTile(
          key: const Key('tripPickOnMap'),
          leading: const Icon(Icons.add_location_alt_outlined),
          title: Text(l.lastMilePickOnMap),
          onTap: () => close(context, _onMap),
        ),
        const Divider(height: 1),
        for (final s in stations)
          ListTile(
            leading: Icon(s.id.startsWith('M') ? Icons.subway : Icons.train,
                color: s.id.startsWith('M') ? AppColors.metro : AppColors.localTrain),
            title: Text(s.name(lang)),
            subtitle: Text(l.stationLabel),
            onTap: () => close(context, _fromStation(s, lang)),
          ),
        for (final p in places)
          ListTile(
            leading: Icon(p.kind == 'housing'
                ? Icons.apartment_outlined
                : Icons.place_outlined),
            title: Text(p.name(lang)),
            subtitle: lang == 'en' ? null : Text(p.nameEn),
            onTap: () => close(
                context,
                TripPoint(
                    name: p.name(lang),
                    point: p.point,
                    source: TripPointSource.place)),
          ),
        if (online)
          _OnlineResults(
            key: ValueKey(q),
            query: q,
            geocoder: geocoder,
            onPick: (r) => close(
                context,
                TripPoint(
                    name: r.name, point: r.point, source: TripPointSource.osm)),
            showEmpty: stations.isEmpty && places.isEmpty,
          )
        else if (q.isNotEmpty && stations.isEmpty && places.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
                q.length < 3 && geocoder.isAvailable
                    ? l.typeMoreToSearch
                    : l.noPlaceFound,
                textAlign: TextAlign.center),
          ),
      ],
    );
  }
}

/// Searches OpenStreetMap after the user pauses typing.
class _OnlineResults extends StatefulWidget {
  const _OnlineResults({
    super.key,
    required this.query,
    required this.geocoder,
    required this.onPick,
    required this.showEmpty,
  });

  final String query;
  final Geocoder geocoder;
  final ValueChanged<GeocodeResult> onPick;
  final bool showEmpty;

  @override
  State<_OnlineResults> createState() => _OnlineResultsState();
}

class _OnlineResultsState extends State<_OnlineResults> {
  Timer? _debounce;
  List<GeocodeResult>? _results;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _debounce = Timer(const Duration(milliseconds: 500), _run);
  }

  Future<void> _run() async {
    try {
      final r = await widget.geocoder.search(widget.query);
      if (mounted) setState(() => _results = r);
    } on GeocodeException {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(l.moreFromOsm, style: text.labelLarge),
    );
    if (_failed) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(l.onlineSearchFailed, style: text.bodySmall),
        ),
      ]);
    }
    final results = _results;
    if (results == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LinearProgressIndicator(),
        ),
      ]);
    }
    if (results.isEmpty) {
      return widget.showEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.noPlaceFound, textAlign: TextAlign.center),
            )
          : const SizedBox.shrink();
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      header,
      for (final r in results)
        ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(r.name),
          subtitle: r.detail.isEmpty ? null : Text(r.detail),
          onTap: () => widget.onPick(r),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Text(l.osmSearchCredit, style: text.bodySmall),
      ),
    ]);
  }
}
