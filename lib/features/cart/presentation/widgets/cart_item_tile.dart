import 'package:flutter/material.dart';

import '../../../../core/money.dart';
import '../../../products/presentation/widgets/product_image.dart';
import '../../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72,
              height: 72,
              child: ProductImage(url: item.product.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(formatCents(item.product.priceCents),
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton.outlined(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Decrease quantity',
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: onDecrement,
                    ),
                    SizedBox(
                      width: 36,
                      child: Text('${item.quantity}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall),
                    ),
                    IconButton.outlined(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Increase quantity',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: onIncrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
              ),
              Text(formatCents(item.subtotalCents),
                  style: theme.textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
