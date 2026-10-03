import 'package:flutter/material.dart';

/// Network image with explicit loading and error states, shared by the product
/// grid and the cart.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (context, error, stack) =>
            const Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
