import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/core/navigation/router.dart';
import 'src/features/cart/application/cart_provider.dart';
import 'src/features/authentication/data/auth_service.dart';
import 'src/core/data/firestore_service.dart';
import 'src/core/theme/theme_provider.dart';
import 'src/features/profile/application/address_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  final appRouter = AppRouter(authService);

  // The router's SplashScreen handles the initial auth state.
  runApp(MyApp(
    appRouter: appRouter,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appRouter,
    required this.authService,
  });

  final AppRouter appRouter;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provides the authentication state throughout the app
        ChangeNotifierProvider<AuthService>.value(value: authService),
        
        // Provides the service for database interactions
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        ChangeNotifierProxyProvider<AuthService, CartProvider>(
          create: (context) => CartProvider(
            context.read<FirestoreService>(),
            context.read<AuthService>(),
          ),
          update: (context, auth, previousCart) => 
              previousCart ?? CartProvider(context.read<FirestoreService>(), auth),
        ),

        ChangeNotifierProxyProvider<AuthService, AddressProvider>(
          create: (context) => AddressProvider(
            firestoreService: context.read<FirestoreService>(),
            authService: context.read<AuthService>(),
          ),
          update: (context, auth, previousProvider) =>
              previousProvider ?? AddressProvider(firestoreService: context.read<FirestoreService>(), authService: auth),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter.router,
        title: 'Gogama Store',
        theme: ThemeProvider.lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
