import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// The app's base map: OpenStreetMap's standard tiles (free, no API key),
/// darkened in dark mode, unless TILE_URL_TEMPLATE points elsewhere.
class AppMapTiles extends ConsumerWidget {
  const AppMapTiles({super.key});

  static const osmStandard = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return TileLayer(
      urlTemplate: config.tileUrlTemplate,
      userAgentPackageName: config.userAgentPackage,
      maxNativeZoom: 19,
      tileBuilder: dark ? darkModeTileBuilder : null,
    );
  }
}

/// Attribution required by OpenStreetMap.
class AppMapAttribution extends StatelessWidget {
  const AppMapAttribution({super.key, this.extra = const []});

  final List<SourceAttribution> extra;

  @override
  Widget build(BuildContext context) {
    return RichAttributionWidget(
      alignment: AttributionAlignment.bottomLeft,
      attributions: [
        const TextSourceAttribution('OpenStreetMap contributors'),
        ...extra,
      ],
    );
  }
}
