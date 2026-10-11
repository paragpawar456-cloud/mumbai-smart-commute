import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/info_state.dart';

/// Phase 4 adds flutter_map with OSM tiles, layers and the user marker.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.mapTitle)),
      body: InfoState(icon: Icons.map, message: l.mapComingSoon),
    );
  }
}
