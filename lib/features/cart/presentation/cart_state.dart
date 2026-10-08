import 'package:equatable/equatable.dart';

import '../models/cart_item.dart';

class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalCents => items.fold(0, (sum, item) => sum + item.subtotalCents);

  @override
  List<Object> get props => [items];
}
