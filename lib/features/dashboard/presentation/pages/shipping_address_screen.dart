import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingAddressScreen extends StatefulWidget {
  final String token;
  final String currentEmail;

  const ShippingAddressScreen({
    super.key,
    required this.currentEmail,
    required this.token,
  });

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final localAddress = prefs.getString(
      '${widget.currentEmail}-shipping_address',
    );

    if (localAddress != null && localAddress.isNotEmpty) {
      setState(() {
        addressController.text = localAddress;
      });
    }

    try {
      // Fetch from backend first
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.token}';

      final response = await dio.get(
        "http://192.168.254.10:3000/api/v1/users/profile",
      );

      // Backend response parsing
      final backendAddress = response.data['data']?['shippingAddress'];

      if (backendAddress != null && backendAddress.isNotEmpty) {
        setState(() {
          addressController.text = backendAddress;
        });
        // Save locally
        await prefs.setString(
          '${widget.currentEmail}-shipping_address',
          backendAddress,
        );
      }
    } catch (e) {
      print("Failed to load backend address: $e");
    }
  }

  Future<void> _saveAddress() async {
    final address = addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Address cannot be empty")));
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userKey = widget.currentEmail;

    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.token}';

      final response = await dio.put(
        "http://192.168.254.10:3000/api/v1/users/shipping-address",
        data: {"shippingAddress": address},
      );

      debugPrint("Address saved backend: ${response.data}");

      // Save locally
      await prefs.setString('$userKey-shipping_address', address);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shipping address saved successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Failed to save address: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save address")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipping Address"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Your Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Address",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
