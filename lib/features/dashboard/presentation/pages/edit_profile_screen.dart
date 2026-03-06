import 'dart:convert';
import 'dart:io';

import 'package:daisy_brew/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  final String token;
  final String fullName;
  final String email;

  final Future<void> Function(String fullName, String email)?
  saveProfileInfoLocally;

  const EditProfileScreen({
    super.key,
    required this.token,
    required this.fullName,
    required this.email,
    this.saveProfileInfoLocally,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.fullName);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.brown,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              buildInputField(
                controller: fullNameController,
                label: "Full Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              buildInputField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 12),
              buildInputField(
                controller: phoneController,
                label: "Phone Number (Optional)",
                icon: Icons.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedFullName = fullNameController.text.trim();
                    final updatedEmail = emailController.text.trim();
                    final updatedPhone = phoneController.text.trim();

                    final baseUrl = Platform.isAndroid
                        ? 'http://192.168.254.50:3000'
                        : 'http://10.0.2.2:3000';

                    try {
                      final response = await http.put(
                        Uri.parse("$baseUrl/api/v1/users/update-profile"),
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer ${widget.token}",
                        },
                        body: jsonEncode({
                          "fullName": updatedFullName,
                          "email": updatedEmail,
                          "phone": updatedPhone,
                        }),
                      );

                      if (response.statusCode == 200) {
                        if (widget.saveProfileInfoLocally != null) {
                          await widget.saveProfileInfoLocally!(
                            updatedFullName,
                            updatedEmail,
                          );
                        }

                        if (!mounted) return;
                        Navigator.pop(context, {
                          "fullName": updatedFullName,
                          "email": updatedEmail,
                        });
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${response.body}")),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
