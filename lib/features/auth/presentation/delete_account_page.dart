import 'package:flas_/core/constants.dart';
import 'package:flas_/features/auth/presentation/auth_errors.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<bool> _confirm() async =>
      await showAdaptiveDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Delete account?'),
          content: const Text(
            'Your account and all synced decks and images will be '
            'permanently deleted, including the decks on this device. '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final auth = ref.read(authProvider.notifier);

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await auth.verifyPassword(_password.text);
      if (!mounted || !await _confirm() || !mounted) return;

      await auth.deleteAccount();
      messenger.showSnackBar(const SnackBar(content: Text('Account deleted')));
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = authMessage(e));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not delete account. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: .all(screenMargin),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: .stretch,
                spacing: 12,
                children: [
                  Text(
                    'Enter your password to permanently delete your account '
                    'and all of its data.',
                    style: TextStyle(
                      fontSize: theme.textTheme.bodyLarge?.fontSize,
                    ),
                  ),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  if (_error != null)
                    Text(_error!, style: TextStyle(color: colors.error)),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : const Text('Delete account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
