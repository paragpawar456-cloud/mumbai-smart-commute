import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/info_state.dart';
import '../account/account_providers.dart';
import 'admin_api.dart';

/// Admin section. Admins see everything; moderators see only Reports.
/// Hiding tabs is a convenience: the server rejects admin calls from anyone
/// whose Users-tab role doesn't allow them.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(serverProfileProvider);
    return profile.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l.adminTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l.adminTitle)),
        body: InfoState(icon: Icons.error_outline, message: l.errorGeneric),
      ),
      data: (p) {
        if (p == null || !p.canModerate) {
          return Scaffold(
            appBar: AppBar(title: Text(l.adminTitle)),
            body: InfoState(icon: Icons.lock_outline, message: l.adminNoAccess),
          );
        }
        final tabs = <(String, Widget)>[
          if (p.isAdmin) (l.adminOverview, const _OverviewTab()),
          (l.adminReports, const _ReportsTab()),
          if (p.isAdmin) (l.adminUsers, const _UsersTab()),
          if (p.isAdmin) (l.adminAlerts, const _AlertsTab()),
          if (p.isAdmin) (l.adminAudit, const _AuditTab()),
        ];
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.adminTitle),
              bottom: TabBar(
                isScrollable: true,
                tabs: [for (final t in tabs) Tab(text: t.$1)],
              ),
            ),
            body: TabBarView(children: [for (final t in tabs) t.$2]),
          ),
        );
      },
    );
  }
}

/// The app theme makes filled buttons full width; inside a Row they must not be.
final _compact = FilledButton.styleFrom(minimumSize: const Size(0, 44));

String _when(BuildContext context, Object? iso) {
  if (iso == null || iso.toString().isEmpty) return '—';
  final d = DateTime.tryParse(iso.toString());
  if (d == null) return iso.toString();
  return DateFormat.yMMMd(Localizations.localeOf(context).toString())
      .add_Hm()
      .format(d.toLocal());
}

/// Loads with [load], shows a spinner, an error with retry, or [builder].
class _Loader<T> extends StatefulWidget {
  const _Loader({super.key, required this.load, required this.builder});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T, VoidCallback reload) builder;

  @override
  State<_Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<_Loader<T>> {
  late Future<T> _future = widget.load();

  void _reload() {
    final next = widget.load();
    setState(() {
      _future = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          final e = snap.error;
          return InfoState(
            icon: Icons.error_outline,
            message: e is ApiException ? e.message : l.errorGeneric,
            actionLabel: l.retry,
            onAction: _reload,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: widget.builder(context, snap.data as T, _reload),
        );
      },
    );
  }
}

Future<void> _run(BuildContext context, Future<void> Function() action,
    VoidCallback reload) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    messenger.showSnackBar(SnackBar(content: Text(l.adminSaved)));
    reload();
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on Exception {
    messenger.showSnackBar(SnackBar(content: Text(l.errorGeneric)));
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final api = ref.read(adminApiProvider);
    return _Loader<Map<String, dynamic>>(
      load: api.overview,
      builder: (context, o, _) {
        final u = (o['users'] as Map).cast<String, dynamic>();
        final r = (o['reports'] as Map).cast<String, dynamic>();
        final dp = (o['dataPack'] as Map).cast<String, dynamic>();
        final sync = (o['sync'] as List).cast<Map>();
        Widget stat(String label, Object? v) => ListTile(
              dense: true,
              title: Text(label),
              trailing: Text('$v',
                  style: Theme.of(context).textTheme.titleMedium),
            );
        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Card(
              child: Column(children: [
                stat(l.adminUsersActive, u['active']),
                stat(l.adminUsersDisabled, u['disabled']),
                stat(l.adminUsersDeleted, u['deleted']),
                stat(l.adminAdmins, u['admins']),
                stat(l.adminModerators, u['moderators']),
              ]),
            ),
            Card(
              child: Column(children: [
                stat(l.adminReportsPending, r['pending']),
                stat(l.adminReportsLive, r['live']),
                stat(l.adminAlertsActive, (o['alerts'] as Map)['active']),
              ]),
            ),
            Card(
              child: Column(children: [
                stat(l.adminDataPackVersion, dp['version']),
                ListTile(
                  dense: true,
                  title: Text(l.adminDataPackPublished),
                  trailing: Text(_when(context, dp['generatedAt'])),
                ),
                ListTile(
                  dense: true,
                  title: Text(l.adminRoadDistance),
                  trailing: Text(o['roadDistanceEnabled'] == true
                      ? l.adminOn
                      : l.adminOff),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
              child: Text(l.adminDataHealth,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (sync.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(l.adminNoSync),
              ),
            for (final s in sync)
              Card(
                child: ListTile(
                  leading: Icon(
                    (s['lastError'] as String).isEmpty
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: (s['lastError'] as String).isEmpty
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                  title: Text(s['sourceId'] as String),
                  subtitle: Text([
                    l.adminLastSuccess(_when(context, s['lastSuccessAt'])),
                    l.adminAcceptedRejected(
                        s['accepted'] as int, s['rejected'] as int),
                    if ((s['lastError'] as String).isNotEmpty) s['lastError'],
                  ].join('\n')),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final api = ref.read(adminApiProvider);
    return _Loader<List<Map<String, dynamic>>>(
      load: api.pendingReports,
      builder: (context, list, reload) => list.isEmpty
          ? ListView(children: [
              InfoState(icon: Icons.inbox_outlined, message: l.adminNoPending),
            ])
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                for (final r in list)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r['type']} · ${r['targetId'] ?? '—'}',
                              style: Theme.of(context).textTheme.titleSmall),
                          if ((r['note'] as String).isNotEmpty) Text(r['note']),
                          Text(
                            '${_when(context, r['createdAt'])} · '
                            '${l.reportConfirmed(r['corroborations'] as int)} · '
                            '${r['lat']}, ${r['lng']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(l.adminReporter(r['reporter'] as String),
                              style: Theme.of(context).textTheme.bodySmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _run(
                                    context,
                                    () => api.moderate(
                                        r['reportId'] as String, 'rejected'),
                                    reload),
                                child: Text(l.adminReject),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: _compact,
                                onPressed: () => _run(
                                    context,
                                    () => api.moderate(
                                        r['reportId'] as String, 'approved'),
                                    reload),
                                child: Text(l.adminApprove),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = ref.read(adminApiProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.adminSearchUsers,
            ),
            onSubmitted: (v) => setState(() => _query = v.trim()),
          ),
        ),
        Expanded(
          child: _Loader<List<Map<String, dynamic>>>(
            key: ValueKey(_query),
            load: () => api.users(_query),
            builder: (context, users, reload) => ListView(
              children: [
                for (final u in users)
                  ListTile(
                    leading: Icon(u['status'] == 'active'
                        ? Icons.person
                        : Icons.person_off_outlined),
                    title: Text((u['email'] as String).isEmpty
                        ? u['uid'] as String
                        : u['email'] as String),
                    subtitle: Text('${u['role']} · ${u['status']} · '
                        '${_when(context, u['createdAt'])}'),
                    trailing: u['status'] == 'deleted'
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (v) {
                              final uid = u['uid'] as String;
                              final Future<void> Function() action =
                                  switch (v) {
                                'disable' => () => api.setStatus(uid, 'disabled'),
                                'enable' => () => api.setStatus(uid, 'active'),
                                _ => () => api.setRole(uid, v),
                              };
                              _run(context, action, reload);
                            },
                            itemBuilder: (_) => [
                              if (u['status'] == 'active')
                                PopupMenuItem(
                                    value: 'disable',
                                    child: Text(l.adminDisable))
                              else
                                PopupMenuItem(
                                    value: 'enable', child: Text(l.adminEnable)),
                              for (final role in ['user', 'moderator', 'admin'])
                                if (role != u['role'])
                                  PopupMenuItem(
                                      value: role,
                                      child: Text(l.adminMakeRole(role))),
                            ],
                          ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final api = ref.read(adminApiProvider);
    return _Loader<List<Map<String, dynamic>>>(
      load: api.alerts,
      builder: (context, alerts, reload) {
        final now = DateTime.now();
        bool active(Map a) {
          final ends = a['endsAt'] == null
              ? null
              : DateTime.tryParse(a['endsAt'] as String);
          return ends == null || ends.isAfter(now);
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const Key('newAlert'),
                onPressed: () async {
                  final saved = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => const _AlertForm(),
                  );
                  if (saved == true) reload();
                },
                icon: const Icon(Icons.add),
                label: Text(l.adminNewAlert),
              ),
            ),
            if (alerts.isEmpty)
              InfoState(icon: Icons.campaign_outlined, message: l.adminNoAlerts),
            for (final a in alerts)
              Card(
                child: ListTile(
                  title: Text(a['titleEn'] as String),
                  subtitle: Text('${a['severity']} · ${a['scope']}\n'
                      '${_when(context, a['startsAt'])} → '
                      '${_when(context, a['endsAt'])}'),
                  isThreeLine: true,
                  trailing: active(a)
                      ? TextButton(
                          onPressed: () => _run(context,
                              () => api.endAlert(a['alertId'] as String), reload),
                          child: Text(l.adminEndAlert),
                        )
                      : Text(l.adminEnded),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AlertForm extends ConsumerStatefulWidget {
  const _AlertForm();

  @override
  ConsumerState<_AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends ConsumerState<_AlertForm> {
  final _form = GlobalKey<FormState>();
  final _scope = TextEditingController(text: 'ALL');
  final _titleEn = TextEditingController();
  final _titleMr = TextEditingController();
  final _titleHi = TextEditingController();
  final _body = TextEditingController();
  final _source = TextEditingController();
  String _severity = 'minor';
  DateTime _starts = DateTime.now();
  DateTime? _ends;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_scope, _titleEn, _titleMr, _titleHi, _body, _source]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return null;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(adminApiProvider).saveAlert({
        'scope': _scope.text.trim(),
        'severity': _severity,
        'titleEn': _titleEn.text.trim(),
        'titleMr': _titleMr.text.trim(),
        'titleHi': _titleHi.text.trim(),
        'bodyEn': _body.text.trim(),
        'startsAt': _starts.toUtc().toIso8601String(),
        if (_ends != null) 'endsAt': _ends!.toUtc().toIso8601String(),
        'sourceUrl': _source.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l.adminRequired : null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(l.adminNewAlert, style: Theme.of(context).textTheme.titleLarge),
            SegmentedButton<String>(
              segments: [
                for (final s in ['info', 'minor', 'major'])
                  ButtonSegment(value: s, label: Text(s)),
              ],
              selected: {_severity},
              onSelectionChanged: (s) => setState(() => _severity = s.first),
            ),
            TextFormField(
              controller: _scope,
              decoration: InputDecoration(
                  labelText: l.adminAlertScope, helperText: l.adminAlertScopeHelp),
              validator: required,
            ),
            TextFormField(
              controller: _titleEn,
              decoration: InputDecoration(labelText: l.adminAlertTitleEn),
              maxLength: 120,
              validator: required,
            ),
            TextFormField(
              controller: _titleMr,
              decoration: InputDecoration(labelText: l.adminAlertTitleMr),
              maxLength: 120,
            ),
            TextFormField(
              controller: _titleHi,
              decoration: InputDecoration(labelText: l.adminAlertTitleHi),
              maxLength: 120,
            ),
            TextFormField(
              controller: _body,
              decoration: InputDecoration(labelText: l.adminAlertBody),
              maxLength: 500,
              maxLines: 3,
            ),
            TextFormField(
              controller: _source,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                  labelText: l.adminAlertSource, helperText: l.adminAlertSourceHelp),
              validator: (v) => v != null && v.trim().startsWith('https://')
                  ? null
                  : l.adminAlertSourceHelp,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.adminAlertStarts),
              trailing: Text(_when(context, _starts.toIso8601String())),
              onTap: () async {
                final d = await _pick(_starts);
                if (d != null) setState(() => _starts = d);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.adminAlertEnds),
              trailing: Text(_ends == null
                  ? l.adminAlertUntilEnded
                  : _when(context, _ends!.toIso8601String())),
              onTap: () async {
                final d = await _pick(_ends ?? _starts);
                if (d != null) setState(() => _ends = d);
              },
            ),
            if (_error != null)
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l.adminPublishAlert),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditTab extends ConsumerWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(adminApiProvider);
    return _Loader<List<Map<String, dynamic>>>(
      load: api.audit,
      builder: (context, entries, _) => ListView(
        children: [
          for (final e in entries)
            ListTile(
              dense: true,
              title: Text('${e['action']} ${e['target'] ?? ''}'),
              subtitle: Text('${_when(context, e['at'])} · ${e['actor']}'
                  '${(e['detail'] as String?)?.isNotEmpty == true ? ' · ${e['detail']}' : ''}'),
            ),
        ],
      ),
    );
  }
}
