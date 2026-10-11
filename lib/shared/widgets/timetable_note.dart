import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/gen/app_localizations.dart';

/// Says where printed train times come from and that they may be out of date.
class TimetableNote extends StatelessWidget {
  const TimetableNote({super.key, required this.validFrom});

  final DateTime validFrom;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    String date;
    try {
      date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
          .format(validFrom);
    } catch (_) {
      date = DateFormat.yMMMd('en').format(validFrom);
    }
    return Container(
      key: const Key('timetableNote'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.timetableSourceNote(date),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
