import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/products/presentation/home_screen.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/catalog_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

// Placeholder for the profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Layar Profil'),
      ),
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Main navigation with tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catalog',
              name: 'catalog',
              builder: (context, state) => const CatalogScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Product Detail is a top-level route
    GoRoute(
      path: '/product/:id',
      name: 'productDetail',
      builder: (context, state) {
        final product = state.extra as Product?;
        final productId = state.pathParameters['id'];

        // --- FIX: Correctly pass parameters to the new ProductDetailScreen constructor ---
        if (product != null) {
          // If the whole product object is passed, use it directly.
          return ProductDetailScreen(product: product);
        } else {
          // Otherwise, pass the ID so the screen can fetch the data itself.
          return ProductDetailScreen(productId: productId);
        }
      },
    ),
    // Cart is a top-level route
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
  ],
);
