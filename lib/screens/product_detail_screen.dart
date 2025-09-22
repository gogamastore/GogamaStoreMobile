import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _quantityController.text = _quantity.toString();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _quantityController.text = _quantity.toString();
      });
    }
  }

  void _onQuantityChanged(String value) {
    final int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity > 0) {
      setState(() {
        _quantity = newQuantity;
      });
    } else if (value.isEmpty) {
      // Allow empty field but don't update quantity until a valid number is entered
      setState(() {
        _quantity = 0; // Or handle as an invalid state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'product_image_${widget.product.id}',
              child: Image.network(
                widget.product.imageUrl,
                height: 300,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  if (widget.product.category.isNotEmpty) Chip(label: Text(widget.product.category), backgroundColor: theme.colorScheme.secondaryContainer),
                  const SizedBox(height: 16.0),
                  Text(formatCurrency.format(widget.product.price), style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Row(children: [Icon(Icons.inventory, size: 16, color: Colors.green[700]), const SizedBox(width: 8.0), Text('${widget.product.stock} tersedia', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.green[700]))]),
                  const Divider(height: 32.0),
                  Text('Deskripsi Produk', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text(widget.product.description.isNotEmpty ? widget.product.description : 'Tidak ada deskripsi untuk produk ini.', style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: theme.cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jumlah:', style: theme.textTheme.titleMedium),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _decrementQuantity),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: theme.textTheme.titleMedium,
                        decoration: const InputDecoration(border: InputBorder.none),
                        onChanged: _onQuantityChanged,
                        onSubmitted: (value) { // Ensure final value is respected
                          final int? newQuantity = int.tryParse(value);
                          if(newQuantity == null || newQuantity <= 0){
                             setState(() {
                                _quantity = 1;
                                _quantityController.text = '1';
                             });
                          }
                        },
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _incrementQuantity),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_quantity > 0) {
                  cartProvider.addItem(widget.product, _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} ditambahkan ke keranjang.'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop(); // Go back to the previous screen
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jumlah harus lebih dari 0.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), textStyle: theme.textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
