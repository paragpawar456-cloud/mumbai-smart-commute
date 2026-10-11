import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/info_state.dart';
import '../settings/settings_controller.dart';
import '../transit/data/transit_providers.dart';
import '../transit/domain/models.dart';
import '../transit/ui/line_badge.dart';
import 'location_service.dart';

final locationServiceProvider = Provider((ref) => const LocationService());

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.focusStationId});

  final String? focusStationId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _kalyan = LatLng(19.2358, 73.1308);
  final _map = MapController();
  LatLng? _me;
  bool _locating = false;
  final Set<TransitMode> _hidden = {};

  @override
  void didUpdateWidget(MapScreen old) {
    super.didUpdateWidget(old);
    if (widget.focusStationId != old.focusStationId) _focusStation();
  }

  void _focusStation() {
    final pack = ref.read(dataPackProvider).value?.pack;
    final s = pack?.stationById[widget.focusStationId];
    if (s != null) _map.move(LatLng(s.lat, s.lng), 15);
  }

  Future<void> _locate() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    try {
      final r = await ref.read(locationServiceProvider).current();
      if (r.problem != null) {
        messenger.showSnackBar(SnackBar(
          content: Text(r.problem == LocationProblem.serviceOff
              ? l.locationServiceOff
              : l.locationDenied),
        ));
        return;
      }
      final p = LatLng(r.lat!, r.lng!);
      setState(() => _me = p);
      _map.move(p, 15);
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l.errorGeneric)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _openStation(Station s) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pack = ref.read(dataPackProvider).value!.pack;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.name(lang), style: Theme.of(c).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final ln in pack.lines.where((x) => x.stationIds.contains(s.id)))
                  LineBadge(line: ln),
              ]),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(c);
                  context.push('/station/${s.id}');
                },
                icon: const Icon(Icons.schedule),
                label: Text(l.departures),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final reducedMotion = ref.watch(settingsProvider).reducedMotion;
    final loaded = ref.watch(dataPackProvider);
    final pack = loaded.value?.pack;
    if (pack == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.mapTitle)),
        body: loaded.hasError
            ? InfoState(icon: Icons.error_outline, message: l.errorGeneric)
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final focus = pack.stationById[widget.focusStationId];
    final visibleLines =
        pack.lines.where((ln) => !_hidden.contains(ln.mode)).toList();
    final visibleStationIds = {for (final ln in visibleLines) ...ln.stationIds};

    return Scaffold(
      appBar: AppBar(
        title: Text(l.mapTitle),
        actions: [
          PopupMenuButton<TransitMode>(
            tooltip: l.layers,
            icon: const Icon(Icons.layers_outlined),
            onSelected: (m) => setState(
                () => _hidden.contains(m) ? _hidden.remove(m) : _hidden.add(m)),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: TransitMode.suburban,
                checked: !_hidden.contains(TransitMode.suburban),
                child: Text(l.layerSuburban),
              ),
              CheckedPopupMenuItem(
                value: TransitMode.metro,
                checked: !_hidden.contains(TransitMode.metro),
                child: Text(l.layerMetro),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l.myLocation,
        onPressed: _locating ? null : _locate,
        child: _locating
            ? const SizedBox.square(
                dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter:
                  focus != null ? LatLng(focus.lat, focus.lng) : _kalyan,
              initialZoom: focus != null ? 15 : 12,
              minZoom: 9,
              maxZoom: 18,
              interactionOptions: InteractionOptions(
                flags: reducedMotion
                    ? InteractiveFlag.all & ~InteractiveFlag.flingAnimation
                    : InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: config.tileUrlTemplate,
                userAgentPackageName: config.userAgentPackage,
              ),
              PolylineLayer(polylines: [
                for (final ln in visibleLines)
                  Polyline(
                    points: [
                      for (final id in ln.stationIds)
                        if (pack.stationById[id] != null)
                          LatLng(pack.stationById[id]!.lat,
                              pack.stationById[id]!.lng),
                    ],
                    color: lineColor(ln),
                    strokeWidth: 4,
                  ),
              ]),
              MarkerLayer(markers: [
                for (final s in pack.stations)
                  if (visibleStationIds.contains(s.id))
                    Marker(
                      point: LatLng(s.lat, s.lng),
                      width: 44,
                      height: 44,
                      child: _StationMarker(
                        station: s,
                        metro: s.id.startsWith('M'),
                        highlighted: s.id == widget.focusStationId,
                        onTap: () => _openStation(s),
                      ),
                    ),
                if (_me != null)
                  Marker(
                    point: _me!,
                    width: 36,
                    height: 36,
                    child: Semantics(
                      label: l.myLocation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(blurRadius: 8, color: Colors.black38)
                          ],
                        ),
                      ),
                    ),
                  ),
              ]),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  const TextSourceAttribution('OpenStreetMap contributors'),
                  TextSourceAttribution(l.lineGeometryNote, prependCopyright: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StationMarker extends StatelessWidget {
  const _StationMarker({
    required this.station,
    required this.metro,
    required this.highlighted,
    required this.onTap,
  });

  final Station station;
  final bool metro;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = metro ? AppColors.metro : AppColors.localTrain;
    return Semantics(
      button: true,
      label: station.nameEn,
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            width: highlighted ? 30 : 22,
            height: highlighted ? 30 : 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: highlighted ? 5 : 3),
            ),
            child: Icon(metro ? Icons.subway : Icons.train,
                size: highlighted ? 16 : 12, color: color),
          ),
        ),
      ),
    );
  }
}
