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

enum NearbyMode { auto, bus }

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
    final pack = ref.watch(dataPackProvider).value!.pack;
    final config = ref.watch(appConfigProvider);
    final data = pack.lastMile;
    final auto = widget.mode == NearbyMode.auto;
    final color = auto ? AppColors.auto : AppColors.bus;
    final here = widget.point;

    final spots = <(String, GeoPoint, double, String?)>[];
    if (auto) {
      for (final p in data.pickupPoints) {
        final m = distanceMeters(here, p.point);
        if (m > 1500) continue;
        spots.add((
          p.nameEn,
          p.point,
          m,
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
    } else {
      for (final s in data.busStops) {
        final m = distanceMeters(here, s.point);
        if (m > 800) continue;
        final routes = data.busRoutes.where((r) => r.stopIds.contains(s.id));
        spots.add((
          s.nameEn,
          s.point,
          m,
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
    }
    spots.sort((a, b) => a.$3.compareTo(b.$3));

    final dest = widget.destination ?? here;
    final providers = auto
        ? [
            for (final pr in data.providers)
              if (pr.bookingUri(here, dest,
                      fromName: widget.placeName,
                      toName: widget.destinationName) !=
                  null)
                pr,
          ]
        : const [];

    return Scaffold(
      appBar: AppBar(title: Text(auto ? l.whereIsMyAuto : l.whereIsMyBus)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 280,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(here.lat, here.lng),
                initialZoom: 15.5,
                minZoom: 11,
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
                      point: LatLng(s.$2.lat, s.$2.lng),
                      width: 56,
                      height: 56,
                      child: _PulsingSpot(
                        pulse: _pulse,
                        color: color,
                        icon: auto ? Icons.electric_rickshaw : Icons.directions_bus,
                      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: color.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Icon(Icons.info_outline, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(auto ? l.noLiveAutos : l.noLiveBuses)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auto
                      ? l.standsNear(widget.placeName)
                      : l.stopsNear(widget.placeName),
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (spots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(auto ? l.nearbyPickupsEmpty : l.noBusData),
                  ),
                for (final s in spots)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.14),
                      child: Icon(
                          auto ? Icons.electric_rickshaw : Icons.directions_bus,
                          color: color),
                    ),
                    title: Text(s.$1),
                    subtitle: Text([
                      l.walkMeters(s.$3.round()),
                      if (s.$4 != null) s.$4!,
                    ].join(' · ')),
                  ),
                if (providers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l.bookInApp,
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l.bookInAppNote, style: text.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final pr in providers)
                      OutlinedButton.icon(
                        onPressed: () => _open(pr.bookingUri(here, dest,
                            fromName: widget.placeName,
                            toName: widget.destinationName)!),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(pr.name),
                      ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
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
