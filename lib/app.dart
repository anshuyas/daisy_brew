import 'package:daisy_brew/app/theme/app_theme.dart';
import 'package:daisy_brew/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:daisy_brew/features/auth/presentation/pages/login_screen.dart';
import 'package:daisy_brew/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:daisy_brew/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'features/dashboard/presentation/pages/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkMode,
      builder: (context, darkModeEnabled, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),
            '/home': (context) => HomeScreen(
              token: "sample_token",
              fullName: 'sample name',
              email: 'sample email',
            ),
          },
        );
      },
    );
  }
}
