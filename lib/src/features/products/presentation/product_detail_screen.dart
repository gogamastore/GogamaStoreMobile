import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/data/firestore_service.dart';
import '../domain/product.dart';
import '../../cart/application/cart_provider.dart';
// --- FIX: Corrected the import path for the QuantitySelector widget ---
import 'widgets/quantity_selector.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final String? productId;

  const ProductDetailScreen({
    super.key,
    this.product,
    this.productId,
  }) : assert(product != null || productId != null, 'Either product or productId must be provided.');

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  Future<Product?>? _fetchProductFuture;
  int _selectedQuantity = 1; // State for the quantity selector

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _product = widget.product;
    } else {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      _fetchProductFuture = firestoreService.getProduct(widget.productId!);
    }
    // If stock is 0, quantity should also be 0
    if (_product?.stock == 0) {
      _selectedQuantity = 0;
    }
  }

  // Callback for the QuantitySelector
  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _selectedQuantity = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_product != null) {
      return _buildProductUI(_product!, context);
    }

    return FutureBuilder<Product?>(
      future: _fetchProductFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Produk tidak dapat ditemukan.')),
          );
        }

        _product = snapshot.data;
        // If stock is 0, quantity should also be 0
        if (_product?.stock == 0) {
          _selectedQuantity = 0;
        }
        return _buildProductUI(_product!, context);
      },
    );
  }

  Widget _buildProductUI(Product product, BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final theme = Theme.of(context);

    // Ensure selected quantity doesn't exceed stock after a rebuild
    if (_selectedQuantity > product.stock) {
      _selectedQuantity = product.stock;
    }
    if (product.stock > 0 && _selectedQuantity == 0) {
      _selectedQuantity = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'product-image-${product.id}',
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                height: 300,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 60)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.category,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stok: ${product.stock}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: product.stock > 0 ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(product.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (product.stock > 0)
              QuantitySelector(
                quantity: _selectedQuantity,
                stock: product.stock,
                onChanged: _onQuantityChanged,
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectedQuantity > 0
                  ? () {
                      context.read<CartProvider>().addItem(product, quantity: _selectedQuantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$_selectedQuantity x ${product.name} ditambahkan ke keranjang.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null, // Disable button if quantity is 0
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
