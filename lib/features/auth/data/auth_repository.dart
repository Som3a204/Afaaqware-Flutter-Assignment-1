class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

/// Mock implementation. Swap for a real one without touching the UI.
class MockAuthRepository implements AuthRepository {
  static const demoEmail = 'test@example.com';
  static const demoPassword = 'password123';

  @override
  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final ok = email.trim().toLowerCase() == demoEmail && password == demoPassword;
    if (!ok) throw const AuthException('Invalid email or password.');
  }

  @override
  Future<void> signOut() async {}
}