import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../models/product.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      body: StreamBuilder<List<Product>>(
        stream: firestoreService.getTrendingProducts(), // Use the new method here
        builder: (context, snapshot) {
          developer.log('Connection State: ${snapshot.connectionState}', name: 'HomeScreen.StreamBuilder');

          if (snapshot.hasError) {
            developer.log('Error: ${snapshot.error}', name: 'HomeScreen.StreamBuilder', error: snapshot.error);
          }
          if (snapshot.hasData) {
            developer.log('Data: ${snapshot.data}', name: 'HomeScreen.StreamBuilder');
          } else {
            developer.log('No data yet.', name: 'HomeScreen.StreamBuilder');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk tren yang ditemukan.'));
          }

          // Filter products based on search query
          final allProducts = snapshot.data!;
          final filteredProducts = _searchQuery.isEmpty
              ? allProducts
              : allProducts
                  .where((product) => product.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          return CustomScrollView(
            slivers: [
              // Sliver App Bar with Search
              SliverAppBar(
                title: const Text('Gogama Store'),
                floating: true,
                pinned: false,
                snap: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          // Add a clear button
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Promotional Banner (optional, can be hidden on search)
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diskon Spesial!',
                              style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dapatkan potongan harga hingga 50% untuk produk pilihan.',
                              style: textTheme.titleMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Categories Section (optional, can be hidden on search)
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text('Kategori', style: textTheme.titleLarge),
                  ),
                ),
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      children: const [
                        _CategoryChip(label: 'Elektronik'),
                        _CategoryChip(label: 'Fashion Pria'),
                        _CategoryChip(label: 'Fashion Wanita'),
                        _CategoryChip(label: 'Kecantikan'),
                        _CategoryChip(label: 'Kesehatan'),
                        _CategoryChip(label: 'Olahraga'),
                      ],
                    ),
                  ),
                ),

              // Products Grid Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                  child: Text(
                      _searchQuery.isEmpty ? 'Produk Tren Teratas' : 'Hasil Pencarian',
                      style: textTheme.titleLarge),
                ),
              ),

              // Show message if no products found after filtering
              if (filteredProducts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Produk yang kamu cari tidak ditemukan.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _ProductCard(product: filteredProducts[index]);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/product_detail', extra: product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-image-${product.id}',
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency.format(product.price),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
