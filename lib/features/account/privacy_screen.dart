import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import 'account_providers.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final sections = [
      (l.privacyCollectTitle, l.privacyCollectBody),
      (l.privacyNotCollectTitle, l.privacyNotCollectBody),
      (l.privacyLocationTitle, l.privacyLocationBody),
      (l.privacyReportsTitle, l.privacyReportsBody),
      (l.privacyRightsTitle, l.privacyRightsBody),
      (l.privacyThirdPartyTitle, l.privacyThirdPartyBody),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.privacyVersion(privacyNoticeVersion), style: text.bodySmall),
          for (final (title, body) in sections) ...[
            const SizedBox(height: 16),
            Text(title, style: text.titleMedium),
            const SizedBox(height: 4),
            Text(body),
          ],
        ],
      ),
    );
  }
}
