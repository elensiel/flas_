import 'package:flas_/core/constants.dart';
import 'package:flas_/features/auth/presentation/auth_errors.dart';
import 'package:flas_/features/auth/presentation/password_rules.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordKey = GlobalKey<FormFieldState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(_currentPassword.text, _newPassword.text);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password updated')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
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
                  controller: _currentPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: _newPassword,
                  obscureText: true,
                  autovalidateMode: .onUserInteraction,
                  maxLength: 72,
                  buildCounter: (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(labelText: 'New password'),
                  onChanged: (_) {
                    if (_confirmPassword.text.isNotEmpty) {
                      _confirmPasswordKey.currentState?.validate();
                    }
                  },
                  validator: validateNewPassword,
                ),
                ListenableBuilder(
                  listenable: _newPassword,
                  builder: (_, _) =>
                      PasswordRuleTiles(password: _newPassword.text),
                ),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: true,
                  autovalidateMode: .onUserInteraction,
                  maxLength: 72,
                  buildCounter: (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                  ),
                  validator: (value) => value == _newPassword.text
                      ? null
                      : 'Passwords do not match',
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
                      : const Text('Update password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
