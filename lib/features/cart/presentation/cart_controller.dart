import 'package:flutter/foundation.dart';

import '../../products/models/product.dart';
import '../models/cart_item.dart';

/// Single source of truth for the cart. Lives above the Navigator, so its data
/// is kept while moving between Home and Cart.
class CartController extends ChangeNotifier {
  // Keyed by product id: O(1) lookups, and a product can never appear twice.
  // Dart's default Map keeps insertion order, so the list order is stable.
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);
  bool get isEmpty => _items.isEmpty;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalCents =>
      _items.values.fold(0, (sum, item) => sum + item.subtotalCents);

  void add(Product product) {
    final existing = _items[product.id];
    _items[product.id] = existing == null
        ? CartItem(product: product)
        : existing.copyWith(quantity: existing.quantity + 1);
    notifyListeners();
  }

  void increment(String productId) {
    final item = _items[productId];
    if (item == null) return;
    _items[productId] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  /// Decreasing below 1 removes the item, so the cart never holds quantity 0.
  void decrement(String productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = item.copyWith(quantity: item.quantity - 1);
    }
    notifyListeners();
  }

  /// Returns the removed item so the UI can offer "Undo".
  CartItem? remove(String productId) {
    final removed = _items.remove(productId);
    if (removed != null) notifyListeners();
    return removed;
  }

  void restore(CartItem item) {
    _items[item.product.id] = item;
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
