import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String token;
  final String fullName;
  final String email;

  const OrderSuccessScreen({
    super.key,
    required this.token,
    required this.fullName,
    required this.email,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  bool showContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EBDD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/coffee_success.json',
              width: 250,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  if (mounted) {
                    setState(() {
                      showContent = true;
                    });
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            if (showContent) ...[
              const Text(
                "Your order has been placed ☕",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        token: widget.token,
                        fullName: widget.fullName,
                        email: widget.email,
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
