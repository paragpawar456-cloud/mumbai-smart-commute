import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import 'saved_journeys_list.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.savedTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [SavedJourneysList()],
      ),
    );
  }
}
