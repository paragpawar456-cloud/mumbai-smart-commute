import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/trip_options.dart';

/// Colour and icon for each way of travelling.
(IconData, Color) modeLook(TripOptionKind k) => switch (k) {
      TripOptionKind.train => (Icons.train, AppColors.localTrain),
      TripOptionKind.auto => (Icons.electric_rickshaw, AppColors.auto),
      TripOptionKind.cab => (Icons.local_taxi, AppColors.taxi),
      TripOptionKind.bus => (Icons.directions_bus, AppColors.bus),
      TripOptionKind.walk => (Icons.directions_walk, AppColors.walk),
    };

String optionTitle(AppLocalizations l, TripOption o) => switch (o.kind) {
      TripOptionKind.train => switch ((o.firstLeg, o.lastLeg)) {
          (LegMode.auto, _) || (_, LegMode.auto) => l.optionTrainAuto,
          _ => l.optionTrain,
        },
      TripOptionKind.auto => l.optionAuto,
      TripOptionKind.cab => l.optionCab,
      TripOptionKind.bus => l.optionBus,
      TripOptionKind.walk => l.optWalk,
    };

String optionFare(AppLocalizations l, TripOption o) {
  if (o.kind == TripOptionKind.walk) return '₹0';
  final f = o.fare;
  if (o.plusTicket) {
    return f == null || f == 0 ? l.fareTrainTicketOnly : l.farePlusTicket(f);
  }
  if (f == null) return o.kind == TripOptionKind.cab ? l.fareInApp : l.fareUnknown;
  return o.fareMinimumOnly ? l.fareFrom(f) : l.fareAbout(f);
}

class _ModeDot extends StatelessWidget {
  const _ModeDot(this.icon, this.color);
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      );
}

/// The chain of modes, e.g. auto → train → walk.
class ModeChain extends StatelessWidget {
  const ModeChain({super.key, required this.option});
  final TripOption option;

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[];
    void leg(LegMode m) {
      if (m == LegMode.auto) {
        dots.add(const _ModeDot(Icons.electric_rickshaw, AppColors.auto));
      } else if (m == LegMode.walk) {
        dots.add(const _ModeDot(Icons.directions_walk, AppColors.walk));
      }
    }

    if (option.kind == TripOptionKind.train) {
      leg(option.firstLeg);
      dots.add(const _ModeDot(Icons.train, AppColors.localTrain));
      leg(option.lastLeg);
    } else {
      final (icon, color) = modeLook(option.kind);
      dots.add(_ModeDot(icon, color));
    }
    final children = <Widget>[];
    for (var i = 0; i < dots.length; i++) {
      if (i > 0) {
        children.add(Icon(Icons.chevron_right,
            size: 16, color: Theme.of(context).colorScheme.outline));
      }
      children.add(dots[i]);
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class TripOptionTile extends StatelessWidget {
  const TripOptionTile({
    super.key,
    required this.option,
    required this.fastest,
    required this.cheapest,
    required this.onTap,
  });

  final TripOption option;
  final bool fastest;
  final bool cheapest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final (_, color) = modeLook(option.kind);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ModeChain(option: option),
                const Spacer(),
                if (option.minutes != null)
                  Text(l.minutesBig(option.minutes!),
                      style: text.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: Text(optionTitle(l, option),
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(optionFare(l, option), style: text.titleSmall),
              ]),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 4, children: [
                if (fastest) _Tag(l.tagFastest, AppColors.localTrain),
                if (cheapest) _Tag(l.tagCheapest, AppColors.auto),
                _Tag(
                    option.trainFromTimetable ? l.tagScheduled : l.tagEstimate,
                    scheme.outline),
              ]),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(l.seeDetails,
                    style: text.labelLarge?.copyWith(color: scheme.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600)),
      );
}
