import 'package:flutter_test/flutter_test.dart';
import 'package:mini_shop/features/cart/presentation/cart_cubit.dart';
import 'package:mini_shop/features/products/models/product.dart';

void main() {
  const apple = Product(id: 'a', name: 'Apple', priceCents: 150, imageUrl: '');
  const pear = Product(id: 'b', name: 'Pear', priceCents: 275, imageUrl: '');

  late CartCubit cubit;
  setUp(() => cubit = CartCubit());
  tearDown(() => cubit.close());

  test('starts empty', () {
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.totalCents, 0);
  });

  test('adding the same product twice increases quantity, not rows', () {
    cubit
      ..add(apple)
      ..add(apple);
    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.single.quantity, 2);
  });

  test('total is computed in cents across products', () {
    cubit
      ..add(apple)
      ..add(apple)
      ..add(pear);
    expect(cubit.state.totalCents, 150 * 2 + 275);
    expect(cubit.state.totalQuantity, 3);
  });

  test('decrement removes the item when quantity reaches zero', () {
    cubit.add(apple);
    cubit.decrement('a');
    expect(cubit.state.isEmpty, isTrue);
  });

  test('increment and decrement adjust quantity', () {
    cubit.add(apple);
    cubit.increment('a');
    expect(cubit.state.items.single.quantity, 2);
    cubit.decrement('a');
    expect(cubit.state.items.single.quantity, 1);
  });

  test('remove returns the item and restore puts it back', () {
    cubit
      ..add(apple)
      ..add(apple);
    final removed = cubit.remove('a');
    expect(cubit.state.isEmpty, isTrue);
    cubit.restore(removed!);
    expect(cubit.state.items.single.quantity, 2);
  });

  test('every change emits a new state', () async {
    final emitted = <int>[];
    final sub = cubit.stream.listen((s) => emitted.add(s.totalQuantity));
    cubit
      ..add(apple)
      ..increment('a');
    await Future<void>.delayed(Duration.zero);
    expect(emitted, [1, 2]);
    await sub.cancel();
  });
}
