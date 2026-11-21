import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/appearance/presentation/appearance_page.dart';
import 'package:flas_/features/auth/presentation/account_page.dart';
import 'package:flas_/features/auth/presentation/auth_page.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(context.icons.person),
            title: Text(
              session == null ? 'Sign in' : 'Account',
              style: TextStyle(fontSize: theme.textTheme.titleLarge?.fontSize),
            ),
            subtitle: Text(
              session == null
                  ? 'Sync your decks across devices'
                  : session.user.email ?? '',
              style: TextStyle(fontSize: theme.textTheme.titleMedium?.fontSize),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    session == null ? const AuthPage() : AccountPage(),
              ),
            ),
          ),
          ListTile(
            leading: Icon(context.icons.palette),
            title: Text(
              'Appearance',
              style: TextStyle(fontSize: theme.textTheme.titleLarge?.fontSize),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppearancePage()),
            ),
          ),
        ],
      ),
    );
  }
}
