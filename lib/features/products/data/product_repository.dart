import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
}

/// Local mock data with a simulated network delay so the loading state is real.
class MockProductRepository implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return _products;
  }

  static String _img(String seed) => 'https://picsum.photos/seed/$seed/400/400';

  static final List<Product> _products = [
    Product(id: 'p1', name: 'Wireless Headphones', priceCents: 7999, imageUrl: _img('headphones')),
    Product(id: 'p2', name: 'Smart Watch', priceCents: 12950, imageUrl: _img('watch')),
    Product(id: 'p3', name: 'Leather Backpack', priceCents: 8900, imageUrl: _img('backpack')),
    Product(id: 'p4', name: 'Running Shoes', priceCents: 6450, imageUrl: _img('shoes')),
    Product(id: 'p5', name: 'Sunglasses', priceCents: 3500, imageUrl: _img('sunglasses')),
    Product(id: 'p6', name: 'Water Bottle', priceCents: 1899, imageUrl: _img('bottle')),
    Product(id: 'p7', name: 'Desk Lamp', priceCents: 2750, imageUrl: _img('lamp')),
    Product(id: 'p8', name: 'Bluetooth Speaker', priceCents: 4999, imageUrl: _img('speaker')),
  ];
}
