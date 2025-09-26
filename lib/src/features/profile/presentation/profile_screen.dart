import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../authentication/data/auth_service.dart';
import '../../authentication/domain/app_user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final AppUser? user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 1,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(context, user, authService),
    );
  }

  Widget _buildProfileContent(BuildContext context, AppUser user, AuthService authService) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildProfileHeader(context, user),
        const SizedBox(height: 24),
        _buildStatsCard(context),
        const SizedBox(height: 24),
        _buildMenuList(context),
        const SizedBox(height: 32),
        _buildSignOutButton(context, authService),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    final imageUrl = user.photoURL.isNotEmpty
        ? user.photoURL
        : 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/profile_pictures%2Fdefault_avatar.png?alt=media&token=16765581-8276-4d04-a5a0-3859e45c4f69';

    return Card(
      elevation: 4,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(imageUrl),
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 3, spreadRadius: 1)
                      ],
                    ),
                    child: const Icon(Icons.edit, size: 20, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(user.whatsapp, style: TextStyle(color: Colors.grey[600]))
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildStatsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, '12', 'Pesanan'),
            _buildStatItem(context, '0', 'Dikirim'),
            _buildStatItem(context, '0', 'Selesai'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildMenuListItem(context, icon: Icons.person_outline, title: 'Profil Saya', subtitle: 'Kelola profil dan informasi pribadi', color: Colors.blue, onTap: () => context.go('/profile/edit')),
          _buildMenuListItem(context, icon: Icons.history, title: 'Riwayat Pesanan', subtitle: 'Lihat status dan riwayat pemesanan', color: Colors.orange, onTap: () => context.go('/profile/orders')),
          _buildMenuListItem(context, icon: Icons.location_on_outlined, title: 'Alamat Pengiriman', subtitle: 'Kelola alamat untuk pengiriman', color: Colors.green, onTap: () => context.go('/profile/address')),
          _buildMenuListItem(context, icon: Icons.support_agent, title: 'Contact', subtitle: 'Hubungi kami dan akun official', color: Colors.lightGreen, onTap: () => context.go('/profile/contact')),
          _buildMenuListItem(context, icon: Icons.help_outline, title: 'Pusat Bantuan', subtitle: 'FAQ dan dukungan pelanggan', color: Colors.purple, onTap: () => context.go('/profile/help')),
          _buildMenuListItem(context, icon: Icons.info_outline, title: 'Tentang Aplikasi', subtitle: 'Informasi aplikasi dan versi', color: Colors.grey, onTap: () {}, hideDivider: true),
        ],
      ),
    );
  }

  Widget _buildMenuListItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap, bool hideDivider = false}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          if (!hideDivider)
            const Divider(height: 1, indent: 70),
        ],
      ),
    );
  }

  void _showSignOutConfirmationDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Keluar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                await authService.signOut(); // Sign out
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthService authService) {
    return ElevatedButton.icon(
      onPressed: () => _showSignOutConfirmationDialog(context, authService),
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
