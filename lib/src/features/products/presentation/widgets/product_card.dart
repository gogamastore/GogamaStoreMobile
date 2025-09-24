import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../domain/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isProductClickable;
  final bool enableHero;

  const ProductCard({
    super.key,
    required this.product,
    this.isProductClickable = true,
    this.enableHero = true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final theme = Theme.of(context);
    final bool isOutOfStock = product.stock <= 0;

    void handleTap() {
      if (isProductClickable && !isOutOfStock) {
        context.push('/product/${product.id}', extra: product);
      }
    }

    // Define the image widget that might be wrapped by Hero
    Widget imageWidget = Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: product.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
        if (isOutOfStock)
          Container(
            color: Colors.black.withAlpha(128),
            alignment: Alignment.center,
            child: const Text(
              'Stok Habis',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: handleTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              // Conditionally wrap the image with a Hero widget
              child: enableHero
                  ? Hero(
                      tag: 'product-image-${product.id}',
                      child: imageWidget,
                    )
                  : imageWidget,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stok: ${product.stock}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: product.stock > 0
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormatter.format(product.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
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
