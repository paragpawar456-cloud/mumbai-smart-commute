import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/info_state.dart';

/// Phase 4 fills this with station search, timetables and journey results.
class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key, this.from, this.to});

  final String? from;
  final String? to;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.routesTitle)),
      body: Column(
        children: [
          if (from != null || to != null)
            ListTile(
              leading: const Icon(Icons.route),
              title: Text('${from ?? '—'}  →  ${to ?? '—'}'),
            ),
          Expanded(
            child: InfoState(
                icon: Icons.schedule, message: l.routesComingSoon),
          ),
        ],
      ),
    );
  }
}
