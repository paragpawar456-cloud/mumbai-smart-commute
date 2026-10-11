import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/source_badge.dart';
import '../data/lastmile_providers.dart';
import '../domain/lastmile_engine.dart';

String _km(double km) => km.toStringAsFixed(1);

class DistanceLine extends StatelessWidget {
  const DistanceLine({super.key, required this.result, required this.road});
  final LastMileResult result;
  final RoadDistance? road;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.kmIsRoad
              ? l.distanceRoad(_km(result.km))
              : l.distanceRoadEstimate(_km(result.km)),
          style: text.titleMedium,
        ),
        Text(
          road != null && road!.attribution.isNotEmpty
              ? '${l.distanceStraight(_km(result.straightKm))} · ${road!.attribution}'
              : l.distanceStraight(_km(result.straightKm)),
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class LastMileOptionCard extends StatelessWidget {
  const LastMileOptionCard({super.key, required this.option});
  final LastMileOption option;

  (IconData, Color) get _look => switch (option.kind) {
        OptionKind.walk => (Icons.directions_walk, AppColors.walk),
        OptionKind.autoMeter => (Icons.electric_rickshaw, AppColors.auto),
        OptionKind.sharedAuto => (Icons.groups_outlined, AppColors.auto),
        OptionKind.taxiMeter => (Icons.local_taxi, AppColors.taxi),
        OptionKind.bus => (Icons.directions_bus, AppColors.bus),
        OptionKind.rideHailing => (Icons.phone_android, AppColors.brand),
      };

  Future<void> _open(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(option.bookingUri!,
        mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(l.couldNotOpen)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final (icon, color) = _look;
    final o = option;
    final title = switch (o.kind) {
      OptionKind.walk => l.optWalk,
      OptionKind.autoMeter => l.optAutoMeter,
      OptionKind.taxiMeter => l.optTaxiMeter,
      OptionKind.sharedAuto => '${l.optSharedAuto} · ${o.pickup!.nameEn}',
      OptionKind.bus => l.optBus(o.busRoute!.operator, o.busRoute!.number),
      OptionKind.rideHailing => o.provider!.name,
    };
    final price = switch (o.kind) {
      OptionKind.walk => '₹0',
      OptionKind.rideHailing => l.fareInApp,
      _ when o.fare != null => o.fare!.minimumOnly
          ? l.fareFrom(o.fare!.amount)
          : l.fareAbout(o.fare!.amount),
      _ when o.fixedFare != null => l.fareShared(o.fixedFare!.round()),
      _ => l.fareUnknown,
    };
    final details = <String>[
      if (o.minutes != null) l.minutesAbout(o.minutes!),
      if (o.kind != OptionKind.walk && o.walkMeters > 0)
        l.walkMeters(o.walkMeters.round()),
      if (o.fare?.nightApplied ?? false) l.nightFareApplied,
      if (o.kind == OptionKind.autoMeter || o.kind == OptionKind.taxiMeter)
        o.pickup != null
            ? l.nearestStand(o.pickup!.nameEn, o.walkMeters.round())
            : l.noStandKnown,
      if (o.kind == OptionKind.bus)
        l.busBoardAlight(o.boardStop!.nameEn, o.alightStop!.nameEn),
      if (o.busRoute?.frequencyNote != null) o.busRoute!.frequencyNote!,
      if (o.pickup?.destinations != null) o.pickup!.destinations!,
      if (o.availability == Availability.unknown && o.kind != OptionKind.rideHailing)
        l.availabilityUnknown,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleSmall),
                  const SizedBox(height: 2),
                  for (final d in details) Text(d, style: text.bodySmall),
                  const SizedBox(height: 6),
                  Row(children: [
                    SourceBadge(kind: o.sourceKind),
                    const Spacer(),
                    if (o.bookingUri != null)
                      TextButton.icon(
                        onPressed: () => _open(context),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(l.openApp(o.provider!.name)),
                      ),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(price, style: text.titleMedium),
          ],
        ),
      ),
    );
  }
}

