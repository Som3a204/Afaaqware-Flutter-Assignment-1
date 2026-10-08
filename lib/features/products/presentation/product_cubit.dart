import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repository) : super(const ProductState());

  final ProductRepository _repository;

  /// Initial load and pull-to-refresh. A full-screen spinner is only shown when
  /// there is nothing to display yet; a refresh keeps the current grid visible.
  Future<void> load() async {
    if (state.products.isEmpty) {
      emit(state.copyWith(status: LoadStatus.loading));
    }
    try {
      final products = await _repository.fetchProducts();
      emit(ProductState(status: LoadStatus.loaded, products: products));
    } catch (_) {
      // Keep stale data if we have it; only show the error view when empty.
      if (state.products.isEmpty) {
        emit(state.copyWith(status: LoadStatus.error));
      }
    }
  }
}
