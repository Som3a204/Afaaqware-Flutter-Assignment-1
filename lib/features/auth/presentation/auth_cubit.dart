import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(const AuthState(status: AuthStatus.loading));

    try {
      await _repository.signIn(email: email, password: password);
      emit(const AuthState(status: AuthStatus.authenticated));
    } on AuthException catch (e) {
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    emit(const AuthState());
  }
}
