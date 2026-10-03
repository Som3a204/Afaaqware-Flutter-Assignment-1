import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';
import '../models/product.dart';

enum LoadStatus { loading, loaded, error }

class ProductController extends ChangeNotifier {
  ProductController(this._repository);

  final ProductRepository _repository;

  List<Product> _products = const [];
  LoadStatus _status = LoadStatus.loading;

  List<Product> get products => _products;
  LoadStatus get status => _status;

  /// Initial load and pull-to-refresh. A full-screen spinner is only shown when
  /// there is nothing to display yet; a refresh keeps the current grid visible.
  Future<void> load() async {
    if (_products.isEmpty) {
      _status = LoadStatus.loading;
      notifyListeners();
    }
    try {
      _products = await _repository.fetchProducts();
      _status = LoadStatus.loaded;
    } catch (_) {
      // Keep stale data if we have it; only show the error view when empty.
      if (_products.isEmpty) _status = LoadStatus.error;
    }
    notifyListeners();
  }
}
