import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Changed icon for catalog
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Bantuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        type: BottomNavigationBarType.fixed, // To ensure all items are visible
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/catalog')) {
      return 1;
    } else if (location.startsWith('/help')) {
      return 2;
    } else if (location.startsWith('/profile')) {
      return 3;
    } else {
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/catalog');
        break;
      case 2:
        context.go('/help');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
