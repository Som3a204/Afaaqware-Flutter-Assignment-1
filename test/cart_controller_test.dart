import 'package:flutter_test/flutter_test.dart';
import 'package:mini_shop/features/cart/presentation/cart_controller.dart';
import 'package:mini_shop/features/products/models/product.dart';

void main() {
  const apple = Product(id: 'a', name: 'Apple', priceCents: 150, imageUrl: '');
  const pear = Product(id: 'b', name: 'Pear', priceCents: 275, imageUrl: '');

  late CartController cart;
  setUp(() => cart = CartController());

  test('adding the same product twice increases quantity, not rows', () {
    cart
      ..add(apple)
      ..add(apple);
    expect(cart.items.length, 1);
    expect(cart.items.single.quantity, 2);
  });

  test('total is computed in cents across products', () {
    cart
      ..add(apple)
      ..add(apple)
      ..add(pear);
    expect(cart.totalCents, 150 * 2 + 275);
    expect(cart.totalQuantity, 3);
  });

  test('decrement removes the item when quantity reaches zero', () {
    cart.add(apple);
    cart.decrement('a');
    expect(cart.isEmpty, isTrue);
  });

  test('increment and decrement adjust quantity', () {
    cart.add(apple);
    cart.increment('a');
    expect(cart.items.single.quantity, 2);
    cart.decrement('a');
    expect(cart.items.single.quantity, 1);
  });

  test('remove returns the item and restore puts it back', () {
    cart
      ..add(apple)
      ..add(apple);
    final removed = cart.remove('a');
    expect(cart.isEmpty, isTrue);
    cart.restore(removed!);
    expect(cart.items.single.quantity, 2);
  });

  test('listeners are notified on change', () {
    var calls = 0;
    cart.addListener(() => calls++);
    cart.add(apple);
    cart.increment('a');
    expect(calls, 2);
  });
}
