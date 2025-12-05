import 'package:daisy_brew/screens/onboarding2_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_cafe, size: 100, color: Colors.brown),
            SizedBox(height: 20),
            Text(
              'Welcome to DaisyBrew',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Order delicious drinks with personalized options.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OnboardingScreen2()),
                );
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
