import 'package:flutter/foundation.dart';

@immutable
class Product {
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
}
