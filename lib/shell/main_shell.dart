import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/decks/presentation/deck_list_page.dart';
import 'package:flas_/features/settings/presentation/menu_page.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [DeckListPage(), MenuPage()],
      ),

      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: Icon(context.icons.style),
              label: 'Decks',
            ),
            NavigationDestination(
              icon: Icon(context.icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
