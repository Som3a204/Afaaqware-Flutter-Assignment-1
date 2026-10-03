import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/money.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _remove(BuildContext context, String productId) {
    final cart = context.read<CartController>();
    final removed = cart.remove(productId);
    if (removed == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removed.product.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cart.restore(removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: cart.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemTile(
                        key: ValueKey(item.product.id),
                        item: item,
                        onIncrement: () => cart.increment(item.product.id),
                        onDecrement: () => cart.decrement(item.product.id),
                        onRemove: () => _remove(context, item.product.id),
                      );
                    },
                  ),
                ),
                _TotalBar(totalCents: cart.totalCents, itemCount: cart.totalQuantity),
              ],
            ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.totalCents, required this.itemCount});

  final int totalCents;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                  style: theme.textTheme.titleMedium),
              Text(formatCents(totalCents),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 64),
          const SizedBox(height: 12),
          const Text('Your cart is empty'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Browse products'),
          ),
        ],
      ),
    );
  }
}
