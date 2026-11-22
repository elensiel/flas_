import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/auth/presentation/change_email_page.dart';
import 'package:flas_/features/auth/presentation/change_password_page.dart';
import 'package:flas_/features/auth/presentation/delete_account_page.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (_, session) {
      if (session == null) Navigator.of(context).popUntil((r) => r.isFirst);
    });

    final theme = Theme.of(context);
    final user = ref.watch(authProvider)?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          Padding(
            padding: .all(screenMargin),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(user?.email ?? '', style: theme.textTheme.titleLarge),
                if (user?.newEmail != null)
                  Text(
                    'Pending: ${user!.newEmail}. Check your inbox to confirm.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(context.icons.mail),
            title: const Text('Change email'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangeEmailPage()),
            ),
          ),
          ListTile(
            leading: Icon(context.icons.lock),
            title: const Text('Change Password'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          ListTile(
            leading: Icon(context.icons.delete),
            title: const Text('Delete account'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(context.icons.logout),
            title: const Text('Sign out'),
            subtitle: const Text('Your decks stay on this device'),
            onTap: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
