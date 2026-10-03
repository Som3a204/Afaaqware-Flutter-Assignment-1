import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../cart/presentation/cart_screen.dart';
import '../models/product.dart';
import 'product_controller.dart';
import 'widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _addToCart(BuildContext context, Product product) {
    context.read<CartController>().add(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _logout(BuildContext context) {
    // The cart belongs to the session, so clear it with the user.
    context.read<CartController>().clear();
    context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          // Selector: only the badge rebuilds when the cart count changes.
          Selector<CartController, int>(
            selector: (_, cart) => cart.totalQuantity,
            builder: (context, count, _) => IconButton(
              tooltip: 'Cart',
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CartScreen()),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Consumer<ProductController>(
        builder: (context, controller, _) {
          switch (controller.status) {
            case LoadStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case LoadStatus.error:
              return _ErrorView(onRetry: controller.load);
            case LoadStatus.loaded:
              if (controller.products.isEmpty) {
                return const Center(child: Text('No products available'));
              }
              return RefreshIndicator(
                onRefresh: controller.load,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () => _addToCart(context, product),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          const Text("Couldn't load products"),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
