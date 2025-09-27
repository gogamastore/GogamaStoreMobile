import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/authentication/data/auth_service.dart';
import 'package:myapp/src/features/authentication/presentation/login_screen.dart';
import 'package:myapp/src/features/authentication/presentation/splash_screen.dart';
import 'package:myapp/src/features/products/presentation/home_screen.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart'; 
import '../../features/orders/presentation/order_history_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/domain/order.dart';
import '../../features/profile/domain/address.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/address_screen.dart';
import '../../features/profile/presentation/add_edit_address_screen.dart';
import '../../features/profile/presentation/contact_screen.dart';
import '../../features/profile/presentation/help_center_screen.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/catalog_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authService,
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authService.authStatus;
      final location = state.matchedLocation;

      // While the auth status is being determined, stay on the splash screen.
      if (authStatus == AuthStatus.unknown) {
        return '/splash';
      }

      final isLoggedIn = authStatus == AuthStatus.authenticated;
      final isGoingToLogin = location == '/login';
      final isGoingToSplash = location == '/splash';

      // If the user is logged in, they should not be on the login or splash screen.
      // Redirect them to the home page.
      if (isLoggedIn && (isGoingToLogin || isGoingToSplash)) {
        return '/';
      }

      // If the user is not logged in, they should be on the login screen.
      // The only exception is if they are already on the splash screen, which will
      // soon be redirected by this very logic.
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // No redirect needed.
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
                  GoRoute(
                    path: 'address',
                    name: 'address',
                    builder: (context, state) => const AddressScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: 'addAddress',
                        builder: (context, state) => const AddEditAddressScreen(),
                      ),
                      GoRoute(
                        path: 'edit',
                        name: 'editAddress',
                        builder: (context, state) {
                          final address = state.extra as Address?;
                          return AddEditAddressScreen(address: address);
                        },
                      ),
                    ]
                  ),
                  GoRoute(
                    path: 'contact',
                    name: 'contact',
                    builder: (context, state) => const ContactScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    name: 'help',
                    builder: (context, state) => const HelpCenterScreen(),
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
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-detail',
        name: 'orderDetail',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderDetailScreen(order: order);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
