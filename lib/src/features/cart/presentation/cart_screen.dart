import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../application/cart_provider.dart';
import '../domain/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text('Keranjang Anda masih kosong', style: theme.textTheme.headlineSmall),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final cartItem = cart.items.values.toList()[i];
                return CartListItem(cartItem: cartItem, currencyFormatter: currencyFormatter);
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Total', style: theme.textTheme.headlineSmall),
                      Text(
                        currencyFormatter.format(cart.totalAmount),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Checkout logic
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}

class CartListItem extends StatelessWidget {
  const CartListItem({
    super.key,
    required this.cartItem,
    required this.currencyFormatter,
  });

  final CartItem cartItem;
  final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          // --- FIX: Added a robust errorBuilder to handle invalid image URLs ---
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              cartItem.product.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          title: Text(
            cartItem.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currencyFormatter.format(cartItem.product.price)),
              const SizedBox(height: 4),
              Text('Kuantitas: ${cartItem.quantity}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => cart.removeItem(cartItem.product.id),
          ),
        ),
      ),
    );
  }
}
