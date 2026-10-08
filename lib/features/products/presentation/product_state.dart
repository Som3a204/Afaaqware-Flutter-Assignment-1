import 'package:equatable/equatable.dart';

import '../models/product.dart';

enum LoadStatus { loading, loaded, error }

class ProductState extends Equatable {
  const ProductState({
    this.status = LoadStatus.loading,
    this.products = const [],
  });

  final LoadStatus status;
  final List<Product> products;

  ProductState copyWith({LoadStatus? status, List<Product>? products}) =>
      ProductState(
        status: status ?? this.status,
        products: products ?? this.products,
      );

  @override
  List<Object> get props => [status, products];
}
