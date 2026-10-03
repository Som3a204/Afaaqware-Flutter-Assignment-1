import 'package:flutter/material.dart';

import '../../../../core/money.dart';
import '../../models/product.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAddToCart});

  final Product product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ProductImage(url: product.imageUrl)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(formatCents(product.priceCents),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FilledButton.tonalIcon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to cart'),
            ),
          ),
        ],
      ),
    );
  }
}
