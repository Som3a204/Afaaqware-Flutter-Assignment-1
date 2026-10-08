import 'package:flutter_bloc/flutter_bloc.dart';

import '../../products/models/product.dart';
import '../models/cart_item.dart';
import 'cart_state.dart';

/// Single source of truth for the cart. It is provided above the Navigator, so
/// its state is kept while moving between Home and Cart.
///
/// State is immutable: every method builds a NEW list and emits a new
/// [CartState]. Mutating the existing list in place would not be detected as a
/// change and the UI would not update.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void add(Product product) {
    final index = _indexOf(product.id);
    final updated = [...state.items];
    if (index == -1) {
      updated.add(CartItem(product: product));
    } else {
      final item = updated[index];
      updated[index] = item.copyWith(quantity: item.quantity + 1);
    }
    emit(CartState(items: updated));
  }

  void increment(String productId) =>
      _change(productId, (item) => item.copyWith(quantity: item.quantity + 1));

  /// Decreasing below 1 removes the item, so the cart never holds quantity 0.
  void decrement(String productId) => _change(
        productId,
        (item) =>
            item.quantity <= 1 ? null : item.copyWith(quantity: item.quantity - 1),
      );

  /// Returns the removed item so the UI can offer "Undo".
  CartItem? remove(String productId) {
    final index = _indexOf(productId);
    if (index == -1) return null;
    final removed = state.items[index];
    _change(productId, (_) => null);
    return removed;
  }

  void restore(CartItem item) =>
      emit(CartState(items: [...state.items, item]));

  void clear() {
    if (state.isEmpty) return;
    emit(const CartState());
  }

  int _indexOf(String productId) =>
      state.items.indexWhere((item) => item.product.id == productId);

  /// Applies [transform] to one item; returning null removes it.
  void _change(String productId, CartItem? Function(CartItem) transform) {
    final index = _indexOf(productId);
    if (index == -1) return;
    final updated = [...state.items];
    final next = transform(updated[index]);
    if (next == null) {
      updated.removeAt(index);
    } else {
      updated[index] = next;
    }
    emit(CartState(items: updated));
  }
}
