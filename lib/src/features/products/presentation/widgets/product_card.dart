import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final theme = Theme.of(context);

    final bool isProductClickable = product.id.isNotEmpty;

    return GestureDetector(
      onTap: isProductClickable
          ? () {
              // --- FIX: Using pushNamed for correct navigation stack behavior ---
              // This ensures the back button always returns to the previous screen (Home or Catalog).
              context.pushNamed(
                'productDetail',
                pathParameters: {'id': product.id},
                extra: product,
              );
            }
          : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Hero(
                tag: 'product-image-${product.id}',
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.isNotEmpty ? product.name : 'Produk Tidak Tersedia',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok: ${product.stock}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: product.stock > 0 ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isProductClickable ? currencyFormatter.format(product.price) : 'Rp 0',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
