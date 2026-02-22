import 'package:daisy_brew/features/auth/presentation/state/auth_state.dart';
import 'package:daisy_brew/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:daisy_brew/core/utils/snackbar_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authViewModelProvider.notifier)
          .sendPasswordResetEmail(emailController.text);

      // Listen to success via state
      final state = ref.read(authViewModelProvider);
      if (state.status == AuthStatus.passwordResetEmailSent) {
        showSnackbar(
          context,
          'Reset token sent to ${emailController.text}',
          color: Colors.green,
        );
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: emailController.text.trim(), // optional
        );
      } else if (state.status == AuthStatus.error) {
        showSnackbar(
          context,
          state.errorMessage ?? 'Failed',
          color: Colors.red,
        );
      }
    } catch (e) {
      showSnackbar(context, 'Failed to send reset email', color: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter your email to receive a password reset link',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email required';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D19C),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.brown)
                      : const Text(
                          'Send Reset Email',
                          style: TextStyle(color: Colors.brown),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
