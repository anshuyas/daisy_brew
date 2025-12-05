import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 100, color: Colors.brown),
            SizedBox(height: 20),
            Text(
              'Pickup or Delivery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Pick up in-store or get it delivered fast.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
