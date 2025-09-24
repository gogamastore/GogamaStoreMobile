import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/authentication/data/auth_service.dart';
import 'package:myapp/src/features/authentication/presentation/login_screen.dart';
import 'package:myapp/src/features/products/presentation/home_screen.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/orders/presentation/order_history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/catalog_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final router = GoRouter(
    refreshListenable: authService,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authService.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
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
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editProfile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'orders',
                    name: 'orderHistory',
                    builder: (context, state) => const OrderHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        builder: (context, state) {
          final product = state.extra as Product?;
          final productId = state.pathParameters['id'];
          if (product != null) {
            return ProductDetailScreen(product: product);
          } else {
            return ProductDetailScreen(productId: productId);
          }
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
