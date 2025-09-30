import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart'; // Impor baru
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../application/cart_provider.dart';

// Model UI-spesifik untuk item keranjang.
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
              child: ListView(
                // Agar bisa pull-to-refresh meskipun kosong
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Keranjang Kosong',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
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
                    const Text('Total:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                          .format(cart.total),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
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
                  onPressed: () {
                    context.push('/checkout');
                  },
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
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
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
    // Cek jika kuantitas dari server/state berubah DAN tidak sama dengan yang ada di input field
    if (widget.item.quantity != oldWidget.item.quantity &&
        widget.item.quantity.toString() != _quantityController.text) {
      final currentSelection = _quantityController.selection;
      final newText = widget.item.quantity.toString();
      _quantityController.text = newText;

      // Amankan posisi kursor. Jika posisi sebelumnya lebih besar dari panjang teks baru,
      // pindahkan kursor ke akhir.
      final newOffset = currentSelection.baseOffset > newText.length
          ? newText.length
          : currentSelection.baseOffset;

      _quantityController.selection =
          TextSelection.collapsed(offset: newOffset);
    }
  }

  void _onQuantityChanged(String value) {
    // Batalkan debounce sebelumnya jika ada
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    int newQuantity = int.tryParse(value) ?? 0;
    final stock = widget.item.stok;

    // --- LOGIKA PINTAR DIMULAI DI SINI ---
    // Jika kuantitas yang diinput melebihi stok
    if (newQuantity > stock) {
      // Langsung perbaiki nilai di text field
      _quantityController.text = stock.toString();
      // Pindahkan kursor ke akhir
      _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length),
      );
      // Atur nilai kuantitas yang akan dikirim ke provider ke nilai stok
      newQuantity = stock;
    }
    // --- LOGIKA PINTAR BERAKHIR DI SINI ---

    // Gunakan debounce untuk mengirim pembaruan ke provider
    _debounce = Timer(const Duration(milliseconds: 800), () {
      // Pastikan nilai tidak negatif
      if (newQuantity < 0) {
        newQuantity = 0;
      }

      // Jika kuantitas menjadi 0, hapus item. Jika tidak, perbarui.
      if (newQuantity == 0) {
        // Jangan panggil removeItem jika widget sudah tidak ada di tree
        if (mounted) {
          context.read<CartProvider>().removeItem(widget.item.productId);
        }
      } else {
        if (mounted) {
          context
              .read<CartProvider>()
              .updateQuantity(widget.item.productId, newQuantity);
        }
      }
    });
  }

  void _updateByButton(int change) {
    final currentVal =
        int.tryParse(_quantityController.text) ?? widget.item.quantity;
    int newQuantity = currentVal + change;

    if (newQuantity > widget.item.stok) newQuantity = widget.item.stok;
    if (newQuantity <= 0) {
      context.read<CartProvider>().removeItem(widget.item.productId);
    } else {
      _quantityController.text = newQuantity.toString();
      context
          .read<CartProvider>()
          .updateQuantity(widget.item.productId, newQuantity);
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
            SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: item.gambar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                          .format(item.harga),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.deepOrange)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero, // Hapus padding
                  constraints: const BoxConstraints(), // Hapus batasan ukuran
                  iconSize: 18.0, // Atur ukuran ikon
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateByButton(-1),
                ),
                SizedBox(
                  width: 25,
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _onQuantityChanged,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero, // Hapus padding
                  constraints: const BoxConstraints(), // Hapus batasan ukuran
                  iconSize: 18.0, // Atur ukuran ikon
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateByButton(-1),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  context.read<CartProvider>().removeItem(item.productId),
            )
          ],
        ),
      ),
    );
  }
}
