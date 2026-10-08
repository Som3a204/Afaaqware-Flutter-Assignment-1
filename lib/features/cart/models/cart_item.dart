import 'package:equatable/equatable.dart';

import '../../products/models/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  int get subtotalCents => product.priceCents * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object> get props => [product, quantity];
}
