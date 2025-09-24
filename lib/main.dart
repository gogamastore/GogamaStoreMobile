import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/core/navigation/router.dart';
import 'src/features/cart/application/cart_provider.dart';
import 'src/features/authentication/data/auth_service.dart';
import 'src/core/data/firestore_service.dart';
import 'src/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Create instances of the services
  final authService = AuthService();

  // Create the router and run the app
  final appRouter = AppRouter(authService);
  runApp(MyApp(appRouter: appRouter, authService: authService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter, required this.authService});

  final AppRouter appRouter;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProxyProvider<AuthService, CartProvider>(
          create: (context) => CartProvider(
            context.read<FirestoreService>(),
            context.read<AuthService>().currentUser?.uid,
          ),
          update: (context, auth, previous) => CartProvider(
            context.read<FirestoreService>(),
            auth.currentUser?.uid,
          ),
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
