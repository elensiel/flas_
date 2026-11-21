import 'package:flas_/core/constants.dart';
import 'package:flas_/features/auth/presentation/auth_errors.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final pending = await ref
          .read(authProvider.notifier)
          .changeEmail(_password.text, _email.text);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pending
                ? 'Check your inbox to confirm the new email'
                : 'Email updated',
          ),
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = authMessage(e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Network error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(authProvider)?.user.email?.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Change email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .all(screenMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 12,
              children: [
                TextFormField(
                  controller: _email,
                  autovalidateMode: .onUserInteraction,
                  keyboardType: .emailAddress,
                  decoration: const InputDecoration(labelText: 'New email'),
                  validator: (value) {
                    final v = (value ?? '').trim().toLowerCase();
                    if (!RegExp(r'^[^\s]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) {
                      return 'Invalid email';
                    }
                    if (v == current) return 'Same as current email';
                    return null;
                  },
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
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : const Text('Update email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
