import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_repository.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
      if (mounted && ref.read(authRepositoryProvider).currentUser != null) {
        context.go('/profile');
      }
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.code == 'auth-unavailable'
            ? l.authUnavailable
            : '${l.errorGeneric} (${e.code})'),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    final auth = ref.read(authRepositoryProvider);
    if (_registering) {
      _run(
        () => auth.registerWithEmail(_email.text, _password.text, _name.text),
        success: l.verifyEmailSent,
      );
    } else {
      _run(() => auth.signInWithEmail(_email.text, _password.text));
    }
  }

  void _forgot() {
    final l = AppLocalizations.of(context);
    if (_email.text.trim().isEmpty) {
      _formKey.currentState!.validate();
      return;
    }
    _run(
      () => ref.read(authRepositoryProvider).sendPasswordReset(_email.text),
      success: l.resetEmailSent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final available = ref.watch(authRepositoryProvider).isAvailable;
    return Scaffold(
      appBar: AppBar(title: Text(_registering ? l.register : l.signIn)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!available)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l.authUnavailable),
                ),
              ),
            Text(l.guestNote),
            const SizedBox(height: 16),
            if (_registering) ...[
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l.displayName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.displayName : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.email),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? l.email : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: l.password),
              validator: (v) => (v == null || v.length < 8) ? l.password : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy || !available ? null : _submit,
              child: Text(_registering ? l.register : l.signIn),
            ),
            if (!_registering)
              TextButton(
                onPressed: _busy || !available ? null : _forgot,
                child: Text(l.forgotPassword),
              ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() => _registering = !_registering),
              child: Text(_registering ? l.signIn : l.register),
            ),
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: _busy || !available
                  ? null
                  : () => _run(
                      () => ref.read(authRepositoryProvider).signInWithGoogle()),
              icon: const Icon(Icons.login),
              label: Text(l.continueWithGoogle),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text(l.continueAsGuest),
            ),
          ],
        ),
      ),
    );
  }
}
