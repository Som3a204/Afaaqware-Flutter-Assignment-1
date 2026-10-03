import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';

enum AuthStatus { unauthenticated, loading, authenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> login({required String email, required String password}) async {
    if (isLoading) return; // ignore double taps
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
    } on AuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Something went wrong. Please try again.';
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.signOut();
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}
