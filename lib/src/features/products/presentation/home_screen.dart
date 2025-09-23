import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/banner_item.dart';
import '../domain/brand.dart';
import '../../../core/data/firestore_service.dart';
import '../domain/product.dart';

import 'widgets/banner_carousel.dart';
import 'widgets/favorite_brand_list.dart';
import 'widgets/trending_product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    // --- Static Data for Banners and Brands (as per the design) ---
    final List<BannerItem> banners = [
      BannerItem(
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/banners%2F1753970600245_scarlett-whitening-foto-scarlettwhiteningcom.jpeg?alt=media&token=74f9c7fd-0266-47a1-b74f-c7fdd0feebae',
        title: 'Scarlett',
        subtitle: 'New Launching product',
      ),
      BannerItem(
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/banners%2F1754162918179_skintific-banner.jpg?alt=media&token=3ab4be99-6c90-42a4-ada4-98bf9e9e795d',
        title: 'Skintific',
        subtitle: 'New Matte Cushion',
      ),
      BannerItem(
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/banners%2F1755509337031_salsa%20banner.png?alt=media&token=05c3b0dd-ac70-4f08-a25a-6acbfecab316',
        title: 'Salsa Beauty',
        subtitle: 'Beauty is Easy',
      ),
    ];

    final List<Brand> brands = [
       Brand(name: 'Glad2Glow', logoUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/brand_logos%2F1755106486152_IMG_7058.png?alt=media&token=5319df76-cfcc-4d4b-ac8c-695b74f7d318'),
      Brand(name: 'Hanasui', logoUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/brand_logos%2F1755106544809_IMG_7059.jpeg?alt=media&token=223dbf3c-9691-46eb-9eeb-af62b0b1598d'),
      Brand(name: 'Barenbliss', logoUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/brand_logos%2F1754592688691_id-11134207-7rbk2-mav8t017c9yj0e.jpeg?alt=media&token=94f2f86e-5169-42bb-b6ff-a62835ec4152'),
      Brand(name: 'Skintific', logoUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/brand_logos%2F1755106446191_IMG_7056.png?alt=media&token=a8364abc-4d5e-4a57-8c29-1ba19494134c'),
      Brand(name: 'Implora', logoUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/brand_logos%2F1755106515388_IMG_7057.jpeg?alt=media&token=3e8de1a9-51ae-4297-82f8-8cc63843e0b7'),
      Brand(name: 'Viva', logoUrl: 'https://firebasestorage.googleapis.com/v0/b/orderflow-r7jsk.firebasestorage.app/o/brand_logos%2F1755106532386_IMG_7060.png?alt=media&token=80ca6e98-0fa7-4e83-9615-7324a4e469b6'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            BannerCarousel(banners: banners),
            const SizedBox(height: 24),
            FavoriteBrandList(brands: brands),
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

                return SizedBox(
                  height: 380, // Adjust height to fit the card properly
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingProducts.length,
                    itemBuilder: (context, index) {
                      final product = trendingProducts[index];
                      return Container(
                        width: 250, // Set a fixed width for the cards in the horizontal list
                        padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8, right: 8),
                        child: TrendingProductCard(product: product),
                      );
                    },
                  ),
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
