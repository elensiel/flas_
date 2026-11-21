import 'package:flas_/core/theme/theme_context.dart';
import 'package:material_ui/material_ui.dart';

class PasswordRules {
  const PasswordRules(this.label, this.test);

  final String label;
  final bool Function(String) test;
}

final passwordRules = <PasswordRules>[
  PasswordRules('At least 8 characters', (v) => v.length >= 8),
  PasswordRules(
    'At least 1 lowercase letter',
    (v) => RegExp(r'[a-z]').hasMatch(v),
  ),
  PasswordRules(
    'At least 1 uppercase letter',
    (v) => RegExp(r'[A-Z]').hasMatch(v),
  ),
  PasswordRules('At least 1 digit', (v) => RegExp(r'\d').hasMatch(v)),
  PasswordRules(
    'At least 1 special character',
    (v) => RegExp(r'[^A-Za-z0-9]').hasMatch(v),
  ),
];

String? validateNewPassword(String? value) =>
    passwordRules.every((rule) => rule.test(value ?? ''))
    ? null
    : 'Password does not meet the requirements';

class PasswordRuleTiles extends StatelessWidget {
  const PasswordRuleTiles({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: .start,
      children: [
        for (final rule in passwordRules)
          Builder(
            builder: (_) {
              final passed = rule.test(password);
              final color = passed ? Colors.green : error;
              return Row(
                children: [
                  Icon(
                    passed ? context.icons.checkCircle : context.icons.cancel,
                    color: password.isNotEmpty ? color : null,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rule.label,
                    style: TextStyle(color: password.isNotEmpty ? color : null),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
