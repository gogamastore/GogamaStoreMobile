import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../application/cart_provider.dart';

// UI-specific model for the cart item.
class CartItemUI {
  final String id;
  final String productId;
  final String nama;
  final double harga;
  final int quantity;
  final String gambar;
  final int stok;

  CartItemUI({
    required this.id,
    required this.productId,
    required this.nama,
    required this.harga,
    required this.quantity,
    required this.gambar,
    required this.stok,
  });

  factory CartItemUI.fromMap(Map<String, dynamic> map) {
    return CartItemUI(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      nama: map['nama'] ?? '',
      harga: (map['harga'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
      gambar: map['gambar'] ?? '',
      stok: map['stok'] as int? ?? 0,
    );
  }

  CartItemUI copyWith({
    int? quantity,
  }) {
    return CartItemUI(
      id: id,
      productId: productId,
      nama: nama,
      harga: harga,
      quantity: quantity ?? this.quantity,
      gambar: gambar,
      stok: stok,
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        // FIX: Use context.pop() from go_router
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Keranjang Belanja'),
      ),
      body: Builder(
        builder: (context) {
          if (cart.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat keranjang...'),
                ],
              ),
            );
          }

          if (cart.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: cart.fetchCart,
              child: ListView( // To allow pull-to-refresh even when empty
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Keranjang Kosong', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Belum ada produk di keranjang Anda'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cart.fetchCart,
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartItemCard(key: ValueKey(item.id), item: item);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(cart.total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () { /* TODO: Implement Checkout */ },
                  child: const Text('Checkout'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final CartItemUI item;

  const _CartItemCard({super.key, required this.item});

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late final TextEditingController _quantityController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != oldWidget.item.quantity &&
        widget.item.quantity.toString() != _quantityController.text) {
      final currentSelection = _quantityController.selection;
      _quantityController.text = widget.item.quantity.toString();
      _quantityController.selection = currentSelection;
    }
  }

  void _onQuantityChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      int newQuantity = int.tryParse(value) ?? widget.item.quantity;

      if (newQuantity > widget.item.stok) {
        newQuantity = widget.item.stok;
      } else if (newQuantity < 0) {
        newQuantity = 0;
      }
      
      if (newQuantity == 0) {
        context.read<CartProvider>().removeItem(widget.item.productId);
      } else {
        context.read<CartProvider>().updateQuantity(widget.item.productId, newQuantity);
      }
    });
  }

  void _updateByButton(int change) {
    final currentVal = int.tryParse(_quantityController.text) ?? widget.item.quantity;
    int newQuantity = currentVal + change;

    if (newQuantity > widget.item.stok) newQuantity = widget.item.stok;
    if (newQuantity <= 0) {
      context.read<CartProvider>().removeItem(widget.item.productId);
    } else {
      _quantityController.text = newQuantity.toString();
      context.read<CartProvider>().updateQuantity(widget.item.productId, newQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(item.gambar, width: 80, height: 80, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(item.harga)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateByButton(-1),
                ),
                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _onQuantityChanged,
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateByButton(1),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => context.read<CartProvider>().removeItem(item.productId),
            )
          ],
        ),
      ),
    );
  }
}
