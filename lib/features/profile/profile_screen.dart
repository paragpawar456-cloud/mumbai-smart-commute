import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../account/account_providers.dart';
import '../auth/auth_repository.dart';
import '../settings/settings_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _languages = <String, String>{
    'en': 'English',
    'mr': 'मराठी',
    'hi': 'हिंदी',
  };

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.deleteAccountConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(c, true), child: Text(l.confirm)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      // Server data first, while the ID token is still valid.
      final api = ref.read(apiClientProvider);
      if (api.isConfigured) {
        await api.call('deleteMyData', authenticated: true);
      }
      await ref.read(authRepositoryProvider).deleteAccount();
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorGeneric)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final user = ref.watch(authStateProvider).value;
    final backend = ref.watch(backendStatusProvider);
    final serverProfile = ref.watch(serverProfileProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _AccountTile(user: user),
          if (serverProfile != null && serverProfile.needsConsent)
            _ConsentCard(onAccept: () => acceptPrivacyNotice(ref)),
          if (serverProfile != null && serverProfile.canModerate)
            ListTile(
              key: const Key('adminTile'),
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(l.adminTitle),
              subtitle: Text(serverProfile.isAdmin ? l.roleAdmin : l.roleModerator),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin'),
            ),
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l.signOut),
              onTap: () => ref.read(authRepositoryProvider).signOut(),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error),
              title: Text(l.deleteAccount),
              onTap: () => _confirmDelete(context, ref),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l.language),
            trailing: DropdownButton<String?>(
              value: settings.locale?.languageCode,
              onChanged: (code) =>
                  controller.setLocale(code == null ? null : Locale(code)),
              items: [
                DropdownMenuItem(value: null, child: Text(l.themeSystem)),
                for (final e in _languages.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l.theme),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (m) => controller.setThemeMode(m!),
              items: [
                DropdownMenuItem(
                    value: ThemeMode.system, child: Text(l.themeSystem)),
                DropdownMenuItem(
                    value: ThemeMode.light, child: Text(l.themeLight)),
                DropdownMenuItem(
                    value: ThemeMode.dark, child: Text(l.themeDark)),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.motion_photos_off_outlined),
            title: Text(l.reducedMotion),
            value: settings.reducedMotion,
            onChanged: controller.setReducedMotion,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: Text(l.backendStatus),
            subtitle: Text(switch (backend.value) {
              BackendStatus.ok => l.backendOk,
              BackendStatus.notConfigured => l.backendNotConfigured,
              BackendStatus.unreachable => l.errorNetwork,
              null => '…',
            }),
            trailing: backend.value == BackendStatus.unreachable
                ? TextButton(
                    onPressed: () => ref.invalidate(backendStatusProvider),
                    child: Text(l.retry))
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.about),
            subtitle: Text(l.aboutBody),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (user == null) {
      return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(l.notSignedIn),
        subtitle: Text(l.guestNote),
        trailing: FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => context.push('/sign-in'),
          child: Text(l.signIn),
        ),
      );
    }
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user!.displayName ?? user!.email ?? ''),
      subtitle: Text(l.signedInAs(user!.email ?? '')),
    );
  }
}

class _ConsentCard extends StatefulWidget {
  const _ConsentCard({required this.onAccept});
  final Future<void> Function() onAccept;

  @override
  State<_ConsentCard> createState() => _ConsentCardState();
}

class _ConsentCardState extends State<_ConsentCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.consentPrompt),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.push('/privacy'),
                  child: Text(l.consentRead),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('acceptPrivacy'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: _busy
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _busy = true);
                          try {
                            await widget.onAccept();
                          } on Exception {
                            messenger.showSnackBar(
                                SnackBar(content: Text(l.errorGeneric)));
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        },
                  child: Text(l.consentAccept),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
