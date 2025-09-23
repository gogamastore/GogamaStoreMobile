import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/product.dart'; // Corrected import path

class TrendingProductCard extends StatelessWidget {
  final Product product;

  const TrendingProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final bool isProductValid = product.id != 'invalid-product';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isProductValid ? () => context.go('/catalog/product/${product.id}', extra: product) : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(product.price),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stok: ${product.stock}',
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(color: product.stock > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
              const Spacer(), // Pushes the button to the bottom
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: isProductValid ? () => context.go('/catalog/product/${product.id}', extra: product) : null,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Lihat Detail'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
