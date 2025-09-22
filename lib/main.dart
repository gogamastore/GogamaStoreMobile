import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';
import 'navigation/router.dart';
import 'providers/cart_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Auto sign-in the user anonymously if they are not already logged in.
  // This ensures that every user has a persistent ID for their cart.
  final authService = AuthService();
  if (authService.currentUser == null) {
    await authService.signInAnonymously();
  }

  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: FirebaseAuth.instance.currentUser, // Use the current user as initial data
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          const Color primarySeedColor = Colors.blue;

          final TextTheme appTextTheme = TextTheme(
            displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
            titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            bodyMedium: GoogleFonts.poppins(fontSize: 14),
            labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          );

          final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primarySeedColor, width: 2.0),
            ),
          );

          final ThemeData lightTheme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primarySeedColor,
              brightness: Brightness.light,
              primary: primarySeedColor,
              onPrimary: Colors.white,
            ),
            textTheme: appTextTheme,
            appBarTheme: AppBarTheme(
              backgroundColor: primarySeedColor,
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primarySeedColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            inputDecorationTheme: inputDecorationTheme,
          );

          final ThemeData darkTheme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primarySeedColor,
              brightness: Brightness.dark,
            ),
            textTheme: appTextTheme,
          );

          return MaterialApp.router(
            routerConfig: router,
            title: 'Gogama Store',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
