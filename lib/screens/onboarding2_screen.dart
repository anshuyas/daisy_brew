import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_drink, size: 100, color: Colors.brown),
            SizedBox(height: 20),
            Text(
              'Customize Your Drink',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Choose size, sugar, ice, toppings and more.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
