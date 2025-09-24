import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/firestore_service.dart';
import '../domain/product.dart';
import 'widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final FirestoreService _firestoreService;
  Stream<List<Product>>? _productsStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _productsStream = _firestoreService.getProductsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Cari produk...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white), // Set text color to white
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Improved error handling to show the actual Firebase error
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat produk. Penyebab: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data ?? [];

          if (_searchQuery.isNotEmpty) {
            products = products.where((product) {
              return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
          }

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada produk yang cocok dengan pencarian Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // The definitive fix: Decreasing childAspectRatio to give cards more height.
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // Decreased from 0.7 to 0.6 to make cards taller.
                childAspectRatio: 0.5,
                crossAxisSpacing: 9.0,
                mainAxisSpacing: 9.0,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
