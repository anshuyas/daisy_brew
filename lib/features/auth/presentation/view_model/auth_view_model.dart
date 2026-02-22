import 'dart:convert';
import 'package:daisy_brew/features/auth/data/repositories/auth_repository.dart';
import 'package:daisy_brew/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/login_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/register_usecase.dart';
import 'package:daisy_brew/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return ForgotPasswordUsecase(repository);
});

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return ResetPasswordUsecase(repository);
});

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return const AuthState();
  }

  // register
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    await Future.delayed(const Duration(seconds: 2));

    final result = await _registerUsecase(
      RegisterParams(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
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

  // login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    await Future.delayed(const Duration(seconds: 2));

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

  // logout
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  //forgot password
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _forgotPasswordUsecase(ForgotPasswordParams(email: email));
      state = state.copyWith(status: AuthStatus.passwordResetEmailSent);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(token: token, newPassword: newPassword),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.passwordResetSuccess);
      },
    );
  }

  // clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
