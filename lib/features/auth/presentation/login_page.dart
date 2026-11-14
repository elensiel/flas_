import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _register = false, _busy = false;
  String? _error, _info;

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
      _info = null;
    });
    final auth = ref.read(authProvider.notifier);
    try {
      if (_register) {
        final signedIn = await auth.register(_email.text, _password.text);
        if (!signedIn && mounted) {
          setState(() => _info = 'Check your email to confirm your account.');
        }
      } else {
        await auth.signIn(_email.text, _password.text);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Network error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: .all(screenMargin),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(
                      context.icons.warning, // todo change with app logo
                      size: 56,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'flas_',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: .center,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: .emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                          ? 'Invalid email'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) => (value == null || value.length < 8)
                          ? 'Min 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                    if (_info != null) Text(_info!),
                    SizedBox(height: 8),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : Text(_register ? 'Register' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _register = !_register;
                        _error = null;
                        _info = null;
                      }),
                      child: Text(
                        _register
                            ? 'Have an account? Sign in'
                            : 'No account? Register',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
