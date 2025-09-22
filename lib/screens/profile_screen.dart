import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    // Listen to the user stream from the provider
    final user = Provider.of<User?>(context);
    final theme = Theme.of(context);

    return Scaffold(
      // The AppBar is now in ScaffoldWithNavBar, so we don't need one here.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: user == null
              ? _buildLoggedOutView(context, authService, theme)
              : _buildLoggedInView(context, authService, user, theme),
        ),
      ),
    );
  }

  // Widget to display when the user is logged out
  Widget _buildLoggedOutView(BuildContext context, AuthService authService, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 20),
        Text(
          'Anda belum masuk.',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Masuk untuk menyimpan keranjang belanja Anda dan melanjutkan kapan saja.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            // Use the AuthService to sign in anonymously
            await authService.signInAnonymously();
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          child: const Text('Masuk Sekarang'),
        ),
      ],
    );
  }

  // Widget to display when the user is logged in
  Widget _buildLoggedInView(BuildContext context, AuthService authService, User user, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.person, size: 60, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 20),
        Text(
          'Selamat Datang!',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Anda masuk sebagai pengguna anonim.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        // Display the user's unique ID for reference
        SelectableText(
          'User ID: ${user.uid}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            // Use the AuthService to sign out
            await authService.signOut();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            backgroundColor: Colors.red[400], // A different color for a destructive action
            foregroundColor: Colors.white,
          ),
          child: const Text('Keluar'),
        ),
      ],
    );
  }
}
