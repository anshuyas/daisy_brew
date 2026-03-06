import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String token;
  const ChangePasswordScreen({super.key, required this.token});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  Future<void> _changePassword() async {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (newPass.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password too short")));
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final dio = Dio();
      final response = await dio.put(
        "http://192.168.254.50:3000/api/v1/users/change-password",
        data: {"currentPassword": current, "newPassword": newPass},
        options: Options(
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      String errorMessage = "Password change failed";

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          errorMessage = e.response!.data["message"] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showText,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Colors.brown),
        suffixIcon: IconButton(
          icon: Icon(
            showText ? Icons.visibility_off : Icons.visibility,
            color: Colors.brown,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.brown[50],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.brown, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade100, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPasswordField(
              controller: currentController,
              label: "Current Password",
              showText: showCurrent,
              toggleVisibility: () =>
                  setState(() => showCurrent = !showCurrent),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: newController,
              label: "New Password",
              showText: showNew,
              toggleVisibility: () => setState(() => showNew = !showNew),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: confirmController,
              label: "Confirm Password",
              showText: showConfirm,
              toggleVisibility: () =>
                  setState(() => showConfirm = !showConfirm),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Change Password",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
