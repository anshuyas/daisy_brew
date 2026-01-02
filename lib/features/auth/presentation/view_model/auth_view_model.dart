import 'package:daisy_brew/features/auth/domain/usecases/login_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    String? phoneNumber,
    String? batchId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    //wait for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    final result = await _registerUsecase(
      RegisterParams(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        phoneNumber: phoneNumber,
        batchId: batchId,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    //wait for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
