import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../authentication/data/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50.0,
              child: Icon(
                Icons.person,
                size: 50.0,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Pengguna Terautentikasi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10.0),
            Text(
              'UID: ${authService.currentUser?.uid ?? 'Tidak ada'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () => context.go('/help'),
              child: const Text('Bantuan'),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}
