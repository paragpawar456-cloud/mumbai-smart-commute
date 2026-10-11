import 'package:flutter/material.dart';

import '../../core/data/data_source_label.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';

/// Small pill saying where a value came from. Shown next to every
/// time-sensitive number so "Scheduled" is never mistaken for "Live".
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.kind});

  final DataSourceKind kind;

  static String label(AppLocalizations l, DataSourceKind kind) => switch (kind) {
        DataSourceKind.live => l.sourceLive,
        DataSourceKind.scheduled => l.sourceScheduled,
        DataSourceKind.estimate => l.sourceEstimate,
        DataSourceKind.official => l.sourceOfficial,
        DataSourceKind.community => l.sourceCommunity,
        DataSourceKind.unknown => l.sourceUnknown,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = AppColors.forSource(kind, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label(l, kind),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
