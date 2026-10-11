import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../data/lastmile_providers.dart';
import '../domain/lastmile_models.dart';

/// Returns a [Place], or the string 'map' when the user wants to pick on the map.
Future<Object?> pickPlace(BuildContext context, LastMileData data) =>
    showSearch<Object?>(
      context: context,
      delegate: _PlaceSearch(data, AppLocalizations.of(context)),
    );

class _PlaceSearch extends SearchDelegate<Object?> {
  _PlaceSearch(this.data, AppLocalizations l)
      : super(searchFieldLabel: l.searchPlaces);

  final LastMileData data;

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
        ? (data.places.toList()..sort((a, b) => a.nameEn.compareTo(b.nameEn)))
        : searchPlaces(data, query);
    return ListView(
      children: [
        ListTile(
          key: const Key('pickOnMapTile'),
          leading: const Icon(Icons.add_location_alt_outlined),
          title: Text(l.lastMilePickOnMap),
          onTap: () => close(context, 'map'),
        ),
        const Divider(height: 1),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.noPlaceFound, textAlign: TextAlign.center),
          ),
        for (final p in results)
          ListTile(
            leading: Icon(p.kind == 'housing'
                ? Icons.apartment_outlined
                : Icons.place_outlined),
            title: Text(p.name(lang)),
            subtitle: lang == 'en' ? null : Text(p.nameEn),
            onTap: () => close(context, p),
          ),
      ],
    );
  }
}
