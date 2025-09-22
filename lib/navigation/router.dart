import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../screens/catalog_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: _GoRouterRefreshStream(AuthService().authStateChanges),
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isLoggingIn = state.uri.toString() == '/login';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/product_detail',
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product != null) {
          return ProductDetailScreen(product: product);
        }
        return const Scaffold(body: Center(child: Text('Product not found')));
      },
    ),
  ],
);

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
