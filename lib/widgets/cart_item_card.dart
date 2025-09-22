import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.cartItem.quantity.toString());
  }

  @override
  void didUpdateWidget(CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cartItem.quantity != int.tryParse(_quantityController.text)) {
      _quantityController.text = widget.cartItem.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(BuildContext context, String value) {
    final int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity >= 0) {
      Provider.of<CartProvider>(context, listen: false).updateItemQuantity(widget.cartItem.product.id, newQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 88,
              height: 88,
              child: Image.network(widget.cartItem.product.imageUrl, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.cartItem.product.name, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(formatCurrency.format(widget.cartItem.product.price), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => cartProvider.updateItemQuantity(widget.cartItem.product.id, widget.cartItem.quantity - 1)),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          controller: _quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onSubmitted: (value) => _onQuantityChanged(context, value),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => cartProvider.updateItemQuantity(widget.cartItem.product.id, widget.cartItem.quantity + 1)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
