import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daisy_brew/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _timer;

  bool _showPassword = false;
  void startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();

    ref.listenManual<AuthState>(authViewModelProvider, (prev, next) {
      setState(() => _isLoading = false);
      if (next.status == AuthStatus.passwordResetSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
      }
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final email = ModalRoute.of(context)?.settings.arguments as String?;
      if (email != null) {
        await ref
            .read(authViewModelProvider.notifier)
            .sendPasswordResetEmail(email);
        startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent to your email')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.brown,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter the 6-digit OTP sent to your email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.length != 6
                    ? "Enter 6-digit OTP"
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? "Minimum 6 characters"
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _canResend
                        ? "You can resend OTP now"
                        : "Resend OTP in $_secondsRemaining s",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: _canResend && !_isLoading ? _resendOtp : null,
                    child: const Text("Resend OTP"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.brown,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            await ref
                                .read(authViewModelProvider.notifier)
                                .resetPassword(
                                  token: otpController.text.trim(),
                                  newPassword: passwordController.text.trim(),
                                );
                            setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
