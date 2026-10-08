import 'package:flutter_test/flutter_test.dart';
import 'package:mini_shop/features/auth/data/auth_repository.dart';
import 'package:mini_shop/features/auth/presentation/auth_cubit.dart';
import 'package:mini_shop/features/auth/presentation/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.shouldFail = false});
  final bool shouldFail;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (shouldFail) throw const AuthException('Invalid email or password.');
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  test('successful login emits loading then authenticated', () async {
    final cubit = AuthCubit(_FakeAuthRepository());
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated),
      ]),
    );
    await cubit.login(email: 'a@b.co', password: 'secret1');
    await expectation;
    await cubit.close();
  });

  test('failed login emits loading then an error message', () async {
    final cubit = AuthCubit(_FakeAuthRepository(shouldFail: true));
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Invalid email or password.',
        ),
      ]),
    );
    await cubit.login(email: 'a@b.co', password: 'wrong11');
    await expectation;
    await cubit.close();
  });

  test('logout returns to the initial unauthenticated state', () async {
    final cubit = AuthCubit(_FakeAuthRepository());
    await cubit.login(email: 'a@b.co', password: 'secret1');
    expect(cubit.state.isAuthenticated, isTrue);
    await cubit.logout();
    expect(cubit.state, const AuthState());
    await cubit.close();
  });
}
