import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/widgets/app_map_tiles.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../domain/lastmile_models.dart';

/// Full-screen map with a fixed centre pin; the user drags the map under it.
Future<GeoPoint?> pickPointOnMap(BuildContext context, GeoPoint start) =>
    Navigator.of(context).push<GeoPoint>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _MapPointPicker(start: start),
    ));

class _MapPointPicker extends ConsumerStatefulWidget {
  const _MapPointPicker({required this.start});
  final GeoPoint start;

  @override
  ConsumerState<_MapPointPicker> createState() => _MapPointPickerState();
}

class _MapPointPickerState extends ConsumerState<_MapPointPicker> {
  final _map = MapController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.lastMilePickOnMap)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: LatLng(widget.start.lat, widget.start.lng),
              initialZoom: 15,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              const AppMapTiles(),
              const AppMapAttribution(),
            ],
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_pin, size: 48, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('usePointButton'),
        onPressed: () {
          final c = _map.camera.center;
          Navigator.pop(context, GeoPoint(c.latitude, c.longitude));
        },
        icon: const Icon(Icons.check),
        label: Text(l.lastMileUseThisPoint),
      ),
    );
  }
}
