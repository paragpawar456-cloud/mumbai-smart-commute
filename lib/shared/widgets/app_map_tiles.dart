import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// The app's base map: CARTO's Voyager style (light) or Dark Matter (dark
/// mode) on OpenStreetMap data, unless TILE_URL_TEMPLATE points elsewhere.
class AppMapTiles extends ConsumerWidget {
  const AppMapTiles({super.key});

  static const cartoLight =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    var url = config.tileUrlTemplate;
    final carto = url.contains('basemaps.cartocdn.com');
    if (carto && dark) url = url.replaceFirst('rastertiles/voyager', 'dark_all');
    return TileLayer(
      urlTemplate: url,
      subdomains: carto ? const ['a', 'b', 'c', 'd'] : const [],
      retinaMode: carto && RetinaMode.isHighDensity(context),
      userAgentPackageName: config.userAgentPackage,
      maxNativeZoom: 19,
    );
  }
}

/// Attribution required by OpenStreetMap and, for the default style, CARTO.
class AppMapAttribution extends ConsumerWidget {
  const AppMapAttribution({super.key, this.extra = const []});

  final List<SourceAttribution> extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carto =
        ref.watch(appConfigProvider).tileUrlTemplate.contains('cartocdn.com');
    return RichAttributionWidget(
      alignment: AttributionAlignment.bottomLeft,
      attributions: [
        const TextSourceAttribution('OpenStreetMap contributors'),
        if (carto) const TextSourceAttribution('CARTO'),
        ...extra,
      ],
    );
  }
}
