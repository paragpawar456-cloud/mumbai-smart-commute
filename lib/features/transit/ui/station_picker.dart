import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../data/transit_providers.dart';
import '../domain/models.dart';
import 'line_badge.dart';

Future<Station?> pickStation(BuildContext context, DataPack pack) =>
    showSearch<Station?>(
      context: context,
      delegate: _StationSearch(pack, AppLocalizations.of(context)),
    );

class _StationSearch extends SearchDelegate<Station?> {
  _StationSearch(this.pack, AppLocalizations l)
      : super(searchFieldLabel: l.searchStations);

  final DataPack pack;

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
    final results = query.trim().isEmpty
        ? (pack.stations.toList()..sort((a, b) => a.nameEn.compareTo(b.nameEn)))
        : searchStations(pack, query, limit: 20);
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l.noStationFound, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final s = results[i];
        final lines = pack.lines.where((ln) => ln.stationIds.contains(s.id));
        return ListTile(
          leading: Icon(
              s.id.startsWith('M') ? Icons.subway_outlined : Icons.train_outlined),
          title: Text(s.name(lang)),
          subtitle: lang == 'en' ? null : Text(s.nameEn),
          trailing: Wrap(
            spacing: 4,
            children: [for (final ln in lines) LineBadge(line: ln, compact: true)],
          ),
          onTap: () => close(context, s),
        );
      },
    );
  }
}
