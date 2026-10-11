import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../transit/data/transit_providers.dart';
import 'journey_store.dart';

/// Saved journeys as tappable rows; used on Home and the Saved tab.
class SavedJourneysList extends ConsumerWidget {
  const SavedJourneysList({super.key, this.limit});

  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pack = ref.watch(dataPackProvider).value?.pack;
    final saved = ref.watch(journeyStoreProvider).saved;
    if (pack == null) return const SizedBox.shrink();
    final rows = saved
        .where((j) =>
            pack.stationById[j.fromId] != null && pack.stationById[j.toId] != null)
        .take(limit ?? saved.length)
        .toList();
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l.noSavedJourneys),
      );
    }
    return Column(
      children: [
        for (final j in rows)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.star),
              title: Text(
                  '${pack.stationById[j.fromId]!.name(lang)} → ${pack.stationById[j.toId]!.name(lang)}'),
              trailing: IconButton(
                tooltip: l.removeJourney,
                icon: const Icon(Icons.close),
                onPressed: () =>
                    ref.read(journeyStoreProvider.notifier).toggleSaved(j),
              ),
              onTap: () => context.go('/routes?fromId=${j.fromId}&toId=${j.toId}'),
            ),
          ),
      ],
    );
  }
}
