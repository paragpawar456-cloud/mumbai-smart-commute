import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/data_source_label.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/source_badge.dart';
import '../transit/domain/models.dart';

/// An official announcement (megablock, cancellation) entered by an admin,
/// always with a link to the source it was copied from.
class ServiceAlert {
  const ServiceAlert({
    required this.id,
    required this.scope,
    required this.severity,
    required this.titleEn,
    this.titleMr,
    this.titleHi,
    required this.body,
    required this.startsAt,
    this.endsAt,
    required this.sourceUrl,
  });

  factory ServiceAlert.fromJson(Map<String, dynamic> j) => ServiceAlert(
        id: j['alertId'] as String,
        scope: j['scope'] as String,
        severity: j['severity'] as String,
        titleEn: j['titleEn'] as String,
        titleMr: j['titleMr'] as String?,
        titleHi: j['titleHi'] as String?,
        body: (j['bodyEn'] as String?) ?? '',
        startsAt: DateTime.parse(j['startsAt'] as String),
        endsAt: j['endsAt'] == null ? null : DateTime.parse(j['endsAt'] as String),
        sourceUrl: j['sourceUrl'] as String,
      );

  final String id;

  /// ALL, a route_id or a station_id.
  final String scope;
  final String severity;
  final String titleEn;
  final String? titleMr;
  final String? titleHi;
  final String body;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String sourceUrl;

  String title(String lang) => switch (lang) {
        'mr' => titleMr ?? titleEn,
        'hi' => titleHi ?? titleEn,
        _ => titleEn,
      };

  bool appliesToStation(DataPack pack, String stationId) =>
      scope == 'ALL' ||
      scope == stationId ||
      pack.lines.any((l) => l.id == scope && l.stationIds.contains(stationId));
}

final alertsProvider = FutureProvider<List<ServiceAlert>>((ref) async {
  final api = ref.watch(apiClientProvider);
  if (!api.isConfigured) return const [];
  final d = await api.call('getAlerts');
  return ((d['alerts'] as List?) ?? const [])
      .map((e) => ServiceAlert.fromJson((e as Map).cast()))
      .toList();
});

/// Cards for the given alerts; nothing at all when there are none, so screens
/// can drop it in without checks. Network errors are silent here: alerts are
/// extra information, never a reason to block the screen.
class AlertBanners extends ConsumerWidget {
  const AlertBanners({super.key, this.where});

  /// Filter, e.g. only alerts that touch a station.
  final bool Function(ServiceAlert)? where;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = (ref.watch(alertsProvider).value ?? const <ServiceAlert>[])
        .where(where ?? (_) => true)
        .toList();
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(children: [for (final a in alerts) _AlertCard(alert: a)]);
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final ServiceAlert alert;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final (icon, color) = switch (alert.severity) {
      'major' => (Icons.report, scheme.error),
      'minor' => (Icons.warning_amber, const Color(0xFFB26A00)),
      _ => (Icons.info_outline, scheme.primary),
    };
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title(lang),
                      style: Theme.of(context).textTheme.titleSmall),
                  if (alert.body.isNotEmpty) Text(alert.body),
                  Row(children: [
                    const SourceBadge(kind: DataSourceKind.official),
                    const Spacer(),
                    TextButton(
                      onPressed: () => launchUrl(Uri.parse(alert.sourceUrl),
                          mode: LaunchMode.externalApplication),
                      child: Text(l.alertSource),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
