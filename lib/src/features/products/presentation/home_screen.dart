import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/banner_item.dart';
import '../domain/brand.dart';
import '../../../core/data/firestore_service.dart';
import '../domain/product.dart';
import 'widgets/product_card.dart';

import 'widgets/banner_carousel.dart';
import 'widgets/favorite_brand_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            StreamBuilder<List<BannerItem>>(
              stream: firestoreService.getBannersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada banner tersedia.'));
                }
                return BannerCarousel(banners: snapshot.data!);
              },
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<Brand>>(
              stream: firestoreService.getBrandsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada brand tersedia.'));
                }
                return FavoriteBrandList(brands: snapshot.data!);
              },
            ),
            const SizedBox(height: 24),

            // --- Trending Products Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produk Trending',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.go('/catalog'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Product>>(
              stream: firestoreService.getTrendingProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada produk trending saat ini.'));
                }

                final trendingProducts = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55, 
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: trendingProducts.length,
                  itemBuilder: (context, index) {
                    final product = trendingProducts[index];
                    // --- FIX: Disable Hero animation on the home screen to prevent tag conflicts ---
                    return ProductCard(product: product, enableHero: false);
                  },
                );
              },
            ),
             const SizedBox(height: 24),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/catalog'),
                icon: const Icon(Icons.storefront),
                label: const Text('Lihat Semua Produk di Katalog'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // full width
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
