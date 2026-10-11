import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/data_source_label.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/info_state.dart';
import '../../shared/widgets/source_badge.dart';
import '../saved/journey_store.dart';
import '../transit/data/data_pack_repository.dart';
import '../transit/data/transit_providers.dart';
import '../transit/domain/models.dart';
import '../transit/domain/route_planner.dart';
import '../transit/ui/journey_card.dart';
import '../transit/ui/station_picker.dart';

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key, this.from, this.to, this.fromId, this.toId});

  /// Free text from the Home search box, resolved to the best station match.
  final String? from;
  final String? to;
  final String? fromId;
  final String? toId;

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  Station? _from;
  Station? _to;
  Journey? _journey;
  bool _searched = false;
  bool _initialised = false;

  void _initFrom(DataPack pack) {
    if (_initialised) return;
    _initialised = true;
    Station? resolve(String? id, String? text) {
      if (id != null) return pack.stationById[id];
      if (text == null || text.trim().isEmpty) return null;
      final hits = searchStations(pack, text, limit: 1);
      return hits.isEmpty ? null : hits.first;
    }

    _from = resolve(widget.fromId, widget.from);
    _to = resolve(widget.toId, widget.to);
    if (_from != null && _to != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _plan());
    }
  }

  void _plan() {
    final planner = ref.read(routePlannerProvider);
    if (planner == null || _from == null || _to == null) return;
    setState(() {
      _searched = true;
      _journey = planner.plan(_from!.id, _to!.id);
    });
    if (_journey != null) {
      ref
          .read(journeyStoreProvider.notifier)
          .addRecent(SavedJourney(_from!.id, _to!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loaded = ref.watch(dataPackProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.routesTitle)),
      body: loaded.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => InfoState(icon: Icons.error_outline, message: l.errorGeneric),
        data: (lp) {
          _initFrom(lp.pack);
          return _body(context, lp);
        },
      ),
    );
  }

  Widget _body(BuildContext context, LoadedPack lp) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pack = lp.pack;
    final lists = ref.watch(journeyStoreProvider);
    final current =
        _from != null && _to != null ? SavedJourney(_from!.id, _to!.id) : null;

    Widget field(String label, IconData icon, Station? value,
            ValueChanged<Station> onPick, Key key) =>
        ListTile(
          key: key,
          leading: Icon(icon),
          title: Text(value?.name(lang) ?? l.selectStation),
          subtitle: Text(label),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () async {
            final s = await pickStation(context, pack);
            if (s != null) {
              setState(() {
                onPick(s);
                _journey = null;
                _searched = false;
              });
            }
          },
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        field(l.fromLabel, Icons.trip_origin, _from, (s) => _from = s,
            const Key('routeFrom')),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: '${l.fromLabel} ⇄ ${l.toLabel}',
            icon: const Icon(Icons.swap_vert),
            onPressed: () => setState(() {
              final t = _from;
              _from = _to;
              _to = t;
              _journey = null;
              _searched = false;
            }),
          ),
        ),
        field(l.toLabel, Icons.place, _to, (s) => _to = s, const Key('routeTo')),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('planButton'),
          onPressed: _from != null && _to != null ? _plan : null,
          icon: const Icon(Icons.alt_route),
          label: Text(l.planJourney),
        ),
        const SizedBox(height: 16),
        if (_searched && _journey == null)
          InfoState(icon: Icons.not_listed_location, message: l.noRouteFound),
        if (_journey != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l.changesCount(_journey!.transfers)} · ${l.stopsCount(_journey!.stops)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                key: const Key('saveJourney'),
                tooltip: lists.saved.contains(current)
                    ? l.removeJourney
                    : l.saveJourney,
                icon: Icon(lists.saved.contains(current)
                    ? Icons.star
                    : Icons.star_outline),
                onPressed: () =>
                    ref.read(journeyStoreProvider.notifier).toggleSaved(current!),
              ),
            ],
          ),
          JourneyCard(journey: _journey!, pack: pack),
        ],
        if (!_searched && lists.recent.isNotEmpty) ...[
          Text(l.recentSearches, style: Theme.of(context).textTheme.titleMedium),
          for (final j in lists.recent)
            if (pack.stationById[j.fromId] != null &&
                pack.stationById[j.toId] != null)
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                    '${pack.stationById[j.fromId]!.name(lang)} → ${pack.stationById[j.toId]!.name(lang)}'),
                onTap: () {
                  setState(() {
                    _from = pack.stationById[j.fromId];
                    _to = pack.stationById[j.toId];
                  });
                  _plan();
                },
              ),
        ],
        const SizedBox(height: 24),
        _DataFooter(lp: lp),
      ],
    );
  }
}

class _DataFooter extends StatelessWidget {
  const _DataFooter({required this.lp});

  final LoadedPack lp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final origin = switch (lp.origin) {
      PackOrigin.bundled => l.originBundled,
      PackOrigin.cached => l.originCached,
      PackOrigin.server => l.originServer,
    };
    final d = lp.pack.generatedAt.toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const SourceBadge(kind: DataSourceKind.official),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l.dataVersion(lp.pack.version, origin)} · '
              '${l.updatedAt('${d.day}/${d.month}/${d.year}')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ]),
        if (lp.refreshError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l.offline, style: Theme.of(context).textTheme.bodySmall),
          ),
        TextButton(
          onPressed: () => context.go('/profile'),
          child: Text(l.about),
        ),
      ],
    );
  }
}
