import 'package:daisy_brew/features/auth/presentation/pages/login_screen.dart';
import 'package:daisy_brew/features/splash/presentation/pages/splash_screen.dart';
import 'package:daisy_brew/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'features/dashboard/presentation/pages/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(token: "sample_token"),
      },
      initialRoute: '/splash',
    );
  }
}
