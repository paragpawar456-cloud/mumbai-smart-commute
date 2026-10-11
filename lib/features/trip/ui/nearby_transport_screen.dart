import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../lastmile/domain/lastmile_engine.dart';
import '../../lastmile/domain/lastmile_models.dart';
import '../../settings/settings_controller.dart';
import '../../transit/data/transit_providers.dart';

enum NearbyMode { auto, bus, cab }

/// "Where is my auto / bus". No live position exists for autos or local
/// buses, so this shows where they are usually found, never a fake vehicle.
class NearbyTransportScreen extends ConsumerStatefulWidget {
  const NearbyTransportScreen({
    super.key,
    required this.mode,
    required this.point,
    required this.placeName,
    this.destination,
    this.destinationName = '',
  });

  final NearbyMode mode;
  final GeoPoint point;
  final String placeName;
  final GeoPoint? destination;
  final String destinationName;

  @override
  ConsumerState<NearbyTransportScreen> createState() => _NearbyState();
}

class _NearbyState extends ConsumerState<NearbyTransportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ref.read(settingsProvider).reducedMotion) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _open(Uri uri) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(l.couldNotOpen)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final pack = ref.watch(dataPackProvider).value!.pack;
    final config = ref.watch(appConfigProvider);
    final data = pack.lastMile;
    final mode = widget.mode;
    final (color, icon, title) = switch (mode) {
      NearbyMode.auto => (AppColors.auto, Icons.electric_rickshaw_rounded, l.whereIsMyAuto),
      NearbyMode.bus => (AppColors.bus, Icons.directions_bus_rounded, l.whereIsMyBus),
      NearbyMode.cab => (AppColors.taxi, Icons.local_taxi_rounded, l.whereIsMyCab),
    };
    final here = widget.point;

    // Every known spot of this kind, nearest first. Within [near] they are
    // "near"; otherwise the three nearest are shown, marked as farther away.
    final all = <_Spot>[];
    if (mode == NearbyMode.bus) {
      for (final s in data.busStops) {
        final routes = data.busRoutes.where((r) => r.stopIds.contains(s.id));
        all.add(_Spot(
          s.nameEn,
          s.point,
          distanceMeters(here, s.point),
          routes.isEmpty
              ? null
              : routes
                  .map((r) => [
                        '${r.operator} ${r.number}',
                        if (r.frequencyNote != null) r.frequencyNote!,
                      ].join(' '))
                  .join(' · '),
        ));
      }
    } else {
      for (final p in data.pickupPoints) {
        final taxi = p.kind == PickupKind.taxiStand;
        if ((mode == NearbyMode.cab) != taxi) continue;
        all.add(_Spot(
          p.nameEn,
          p.point,
          distanceMeters(here, p.point),
          [
            switch (p.kind) {
              PickupKind.sharedAuto => l.optSharedAuto,
              PickupKind.taxiStand => l.optTaxiMeter,
              _ => l.autoStand,
            },
            if (p.destinations != null) p.destinations!,
            switch (p.verification) {
              Verification.adminVerified => l.verificationAdmin,
              Verification.osm => l.verificationOsm,
              Verification.community => l.verificationCommunity,
            },
          ].join(' · '),
        ));
      }
    }
    all.sort((a, b) => a.meters.compareTo(b.meters));
    final near = mode == NearbyMode.bus ? 1000.0 : 2000.0;
    var spots = all.where((s) => s.meters <= near).toList();
    final farther = spots.isEmpty && all.isNotEmpty;
    if (farther) spots = all.where((s) => s.meters <= 8000).take(3).toList();

    final dest = widget.destination ?? here;
    final providers = mode == NearbyMode.bus
        ? const []
        : [
            for (final pr in data.providers)
              if (pr.bookingUri(here, dest,
                      fromName: widget.placeName,
                      toName: widget.destinationName) !=
                  null)
                pr,
          ];

    final points = [here, for (final s in spots) s.point];
    final bounds = LatLngBounds.fromPoints(
        [for (final p in points) LatLng(p.lat, p.lng)]);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(here.lat, here.lng),
                initialZoom: 15,
                initialCameraFit: points.length > 1
                    ? CameraFit.bounds(
                        bounds: bounds,
                        padding: const EdgeInsets.all(48),
                        maxZoom: 16.5)
                    : null,
                minZoom: 10,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: config.tileUrlTemplate,
                  userAgentPackageName: config.userAgentPackage,
                ),
                MarkerLayer(markers: [
                  for (final s in spots)
                    Marker(
                      point: LatLng(s.point.lat, s.point.lng),
                      width: 56,
                      height: 56,
                      child: _PulsingSpot(pulse: _pulse, color: color, icon: icon),
                    ),
                  Marker(
                    point: LatLng(here.lat, here.lng),
                    width: 28,
                    height: 28,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black38)
                        ],
                      ),
                    ),
                  ),
                ]),
                const RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [TextSourceAttribution('OpenStreetMap contributors')],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (providers.isNotEmpty) ...[
                  Card(
                    key: const Key('liveInAppsCard'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.bolt_rounded, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(l.seeLiveInApp, style: text.titleMedium)),
                          ]),
                          const SizedBox(height: 6),
                          Text(l.liveCabsInApps,
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          Row(children: [
                            for (final (i, pr) in providers.indexed) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(46)),
                                  onPressed: () => _open(pr.bookingUri(here, dest,
                                      fromName: widget.placeName,
                                      toName: widget.destinationName)!),
                                  child: Text(pr.name),
                                ),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  switch (mode) {
                    NearbyMode.auto => l.standsNear(widget.placeName),
                    NearbyMode.bus => l.stopsNear(widget.placeName),
                    NearbyMode.cab => l.taxiStandsNear(widget.placeName),
                  },
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (farther)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(l.nearestFarAway,
                        style: text.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                const SizedBox(height: 8),
                if (spots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(switch (mode) {
                      NearbyMode.auto => l.nearbyPickupsEmpty,
                      NearbyMode.bus => l.noBusData,
                      NearbyMode.cab => l.noTaxiStands,
                    }),
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      for (final (i, s) in spots.indexed) ...[
                        if (i > 0) const Divider(indent: 72),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.14),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(s.name),
                          subtitle: Text([
                            s.meters < 1000
                                ? l.walkMeters(s.meters.round())
                                : l.kmAway((s.meters / 1000).toStringAsFixed(1)),
                            ?s.detail,
                          ].join(' · ')),
                        ),
                      ],
                    ]),
                  ),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mode == NearbyMode.bus ? l.noLiveBuses : l.noLiveAutos,
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spot {
  const _Spot(this.name, this.point, this.meters, this.detail);

  final String name;
  final GeoPoint point;
  final double meters;
  final String? detail;
}

class _PulsingSpot extends StatelessWidget {
  const _PulsingSpot({required this.pulse, required this.color, required this.icon});
  final Animation<double> pulse;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: pulse,
        builder: (_, child) => Stack(alignment: Alignment.center, children: [
          Container(
            width: 20 + 34 * pulse.value,
            height: 20 + 34 * pulse.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.4 * (1 - pulse.value)),
            ),
          ),
          child!,
        ]),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      );
}
