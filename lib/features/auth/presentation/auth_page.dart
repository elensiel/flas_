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
        context.icons.warning, // todo change with app logo
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
            autovalidateMode: .onUserInteraction,
            keyboardType: .emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch((value ?? '').trim())
                ? null
                : 'Invalid email',
          ),
          TextFormField(
            controller: _password,
            autovalidateMode: .onUserInteraction,
            maxLength: 72,
            buildCounter: (
              _, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
            obscureText: true,
            autofillHints: [
              _register ? AutofillHints.newPassword : AutofillHints.password,
            ],
            decoration: InputDecoration(
              labelText: _register ? 'Set Password' : 'Password',
            ),
            onChanged: (_) {
              if (_register && _confirmPassword.text.isNotEmpty) {
                _confirmPasswordKey.currentState?.validate();
              }
            },
            validator: _register
                ? validateNewPassword
                : (value) => (value == null) ? "Required" : null,
          ),
          if (_register)
            ListenableBuilder(
              listenable: _password,
              builder: (_, _) => PasswordRuleTiles(password: _password.text),
            ),
          if (_register)
            TextFormField(
              key: _confirmPasswordKey,
              controller: _confirmPassword,
              autovalidateMode: .onUserInteraction,
              maxLength: 72,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              validator: (value) =>
                  value == _password.text ? null : 'Passwords does not match',
            ),
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
        onPressed: () => setState(() {
          // cache typed fields
          final emailTmp = _email.text;
          final passwordTmp = _password.text;

          // re apply typed fields and validate again
          _register = !_register;
          _formKey.currentState?.reset();
          _email.text = emailTmp;
          _password.text = passwordTmp;
          _formKey.currentState?.validate();
        }),
        child: Text(
          _register ? 'Have an account? Sign in' : 'No account? Register now.',
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
    ],
  );
}
