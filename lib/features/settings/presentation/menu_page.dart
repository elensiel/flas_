import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/appearance/presentation/appearance_page.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: ListView(
        children: [
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
