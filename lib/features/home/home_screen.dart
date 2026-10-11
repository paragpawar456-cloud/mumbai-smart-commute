import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../alerts/alerts.dart';
import '../saved/saved_journeys_list.dart';
import '../trip/domain/trip_point.dart';
import '../trip/ui/location_search.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TripPoint? _from;
  TripPoint? _to;

  void _swap() => setState(() {
        final f = _from;
        _from = _to;
        _to = f;
      });

  Future<TripPoint?> _pick(bool isFrom) async {
    final p = await pickTripPoint(context, ref, allowMyLocation: isFrom);
    if (p != null) setState(() => isFrom ? _from = p : _to = p);
    return p;
  }

  Future<void> _search() async {
    if (_from == null && await _pick(true) == null) return;
    if (_to == null && await _pick(false) == null) return;
    if (!mounted) return;
    final from = _from!, to = _to!;
    if (from.isStation && to.isStation) {
      context.go(Uri(path: '/routes', queryParameters: {
        'fromId': from.stationId!,
        'toId': to.stationId!,
      }).toString());
    } else {
      context.push(Uri(path: '/trip', queryParameters: {
        ...from.toQuery('from'),
        ...to.toQuery('to'),
      }).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AlertBanners(),
          Text(l.homeGreeting, style: text.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _PointField(
                              key: const Key('fromField'),
                              label: l.fromLabel,
                              hint: l.fromHint,
                              icon: Icons.my_location,
                              value: _from,
                              onTap: () => _pick(true),
                            ),
                            const SizedBox(height: 12),
                            _PointField(
                              key: const Key('toField'),
                              label: l.toLabel,
                              hint: l.toHint,
                              icon: Icons.place,
                              value: _to,
                              onTap: () => _pick(false),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: '${l.fromLabel} ⇄ ${l.toLabel}',
                        onPressed: _swap,
                        icon: const Icon(Icons.swap_vert),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('findRoutesButton'),
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                    label: Text(l.findRoutes),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              key: const Key('lastMileCard'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.electric_rickshaw,
                  size: 32, color: AppColors.auto),
              title: Text(l.lastMileTitle, style: text.titleMedium),
              subtitle: Text(l.lastMileHomeBody),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/last-mile'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const _ModeIcons(),
              title: Text(l.nearbyTransport, style: text.titleMedium),
              subtitle: Text(l.nearbyTransportBody),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/map'),
            ),
          ),
          const SizedBox(height: 24),
          Text(l.savedJourneys, style: text.titleMedium),
          const SizedBox(height: 8),
          const SavedJourneysList(limit: 3),
        ],
      ),
    );
  }
}

/// Looks like a text box; tapping it opens the place search.
class _PointField extends StatelessWidget {
  const _PointField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TripPoint? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            isEmpty: value == null,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(icon),
            ),
            child: value == null
                ? null
                : Text(value!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      );
}

class _ModeIcons extends StatelessWidget {
  const _ModeIcons();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 48,
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            Icon(Icons.train, size: 20, color: AppColors.localTrain),
            Icon(Icons.directions_bus, size: 20, color: AppColors.bus),
            Icon(Icons.electric_rickshaw, size: 20, color: AppColors.auto),
            Icon(Icons.local_taxi, size: 20, color: AppColors.taxi),
          ],
        ),
      );
}
