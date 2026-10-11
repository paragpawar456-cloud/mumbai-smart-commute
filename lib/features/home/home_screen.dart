import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../alerts/alerts.dart';
import '../saved/saved_journeys_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _from = TextEditingController();
  final _to = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  void _swap() {
    final f = _from.text;
    _from.text = _to.text;
    _to.text = f;
  }

  void _search() {
    context.go(Uri(path: '/routes', queryParameters: {
      if (_from.text.trim().isNotEmpty) 'from': _from.text.trim(),
      if (_to.text.trim().isNotEmpty) 'to': _to.text.trim(),
    }).toString());
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
                            TextField(
                              key: const Key('fromField'),
                              controller: _from,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l.fromLabel,
                                hintText: l.fromHint,
                                prefixIcon: const Icon(Icons.my_location),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              key: const Key('toField'),
                              controller: _to,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _search(),
                              decoration: InputDecoration(
                                labelText: l.toLabel,
                                hintText: l.toHint,
                                prefixIcon: const Icon(Icons.place),
                              ),
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
