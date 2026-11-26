import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/auth/presentation/password_rules.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordKey = GlobalKey<FormFieldState<String>>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _register = false, _busy = false;
  String? _error, _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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

  void _toggleMode() => setState(() {
    // cache typed fields
    final emailTmp = _email.text;
    final passwordTmp = _password.text;

    // re apply typed fields
    _register = !_register;
    _formKey.currentState?.reset();
    _email.text = emailTmp;
    _password.text = passwordTmp;

    // validate if user started filling up
    if (emailTmp.isNotEmpty || passwordTmp.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  });

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, session) {
      if (session != null) Navigator.of(context).popUntil((r) => r.isFirst);
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: .all(screenMargin),
              child: Column(
                spacing: 12,
                children: [_header(), _form(), _actionButtons()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Column(
    spacing: 8,
    children: [
      Icon(
        context.icons.style,
        size: 56,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      Text(
        'flas_',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: .center,
      ),
    ],
  );

  Widget _form() => Form(
    key: _formKey,
    child: AutofillGroup(
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) => (value?.isEmpty == true)
                ? 'Required'
                : RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch((value ?? '').trim())
                ? null
                : 'Invalid email',
            autovalidateMode: .onUserInteraction,
            keyboardType: .emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(
              labelText: _register ? 'Set Password' : 'Password',
            ),
            validator: _register
                ? validateNewPassword
                : (value) => (value?.isEmpty == true) ? 'Required' : null,
            autovalidateMode: .onUserInteraction,
            obscureText: true,
            maxLength: 72,
            buildCounter: (
              _, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
            autofillHints: [
              _register ? AutofillHints.newPassword : AutofillHints.password,
            ],
            onChanged: (_) {
              if (_register && _confirmPassword.text.isNotEmpty) {
                _confirmPasswordKey.currentState?.validate();
              }
            },
          ),
          if (_register) ...[
            ListenableBuilder(
              listenable: _password,
              builder: (_, _) => PasswordRuleTiles(password: _password.text),
            ),
            TextFormField(
              key: _confirmPasswordKey,
              controller: _confirmPassword,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              validator: (value) =>
                  value == _password.text ? null : 'Passwords do not match',
              autovalidateMode: .onUserInteraction,
              obscureText: true,
              maxLength: 72,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              autofillHints: const [AutofillHints.newPassword],
            ),
          ],
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_info != null) Text(_info!),
        ],
      ),
    ),
  );

  Widget _actionButtons() => Column(
    crossAxisAlignment: .stretch,
    children: [
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(),
              )
            : Text(_register ? 'Register' : 'Sign In'),
      ),
      TextButton(
        onPressed: _toggleMode,
        child: Text(
          _register ? 'Have an account? Sign in' : 'No account? Register now.',
          style: const TextStyle(color: Colors.blueAccent),
        ),
      ),
    ],
  );
}
