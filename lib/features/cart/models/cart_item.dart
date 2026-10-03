import 'package:flutter/foundation.dart';

import '../../products/models/product.dart';

@immutable
class CartItem {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  int get subtotalCents => product.priceCents * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}
