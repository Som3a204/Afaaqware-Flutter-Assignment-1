import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int priceCents;
  final String imageUrl;

  @override
  List<Object> get props => [id, name, priceCents, imageUrl];
}
