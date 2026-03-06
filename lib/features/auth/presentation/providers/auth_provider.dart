import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthState {
  final String? token;
  final String? email; // optional, for user info
  AuthState({this.token, this.email});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setAuth({required String token, required String email}) {
    state = AuthState(token: token, email: email);
  }

  void clearAuth() {
    state = AuthState(token: null, email: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Shortcut provider to just get the token
final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).token;
});
