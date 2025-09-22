import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../screens/cart_screen.dart';
import '../screens/catalog_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/signup_screen.dart'; // Import SignUpScreen
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
    // Check if the user is on the login or signup page.
    final bool isOnAuthFlow = state.uri.toString() == '/login' || state.uri.toString() == '/signup';

    // If the user is not logged in and not on an auth page, redirect to login.
    if (!isLoggedIn && !isOnAuthFlow) {
      return '/login';
    }

    // If the user is logged in and tries to access an auth page, redirect to home.
    if (isLoggedIn && isOnAuthFlow) {
      return '/';
    }

    return null; // No redirect needed.
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/catalog', builder: (context, state) => const CatalogScreen()),
        GoRoute(path: '/help', builder: (context, state) => const HelpCenterScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Add the route for the sign-up screen.
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      name: 'productDetail',
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product != null) {
          return ProductDetailScreen(product: product);
        }
        return const Scaffold(body: Center(child: Text('Product not found')));
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
  ],
);

// A stream-based ChangeNotifier for go_router to listen to auth state changes.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
