import 'package:daisy_brew/features/onboarding/presentation/pages/onboarding1_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _steamController;

  @override
  void initState() {
    super.initState();

    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _steamController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_steamController == null) {
      return const SizedBox(); // safety fallback
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF6E6D6),
                  Color(0xFFD2B48C),
                  Color(0xFF8B5E3C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Curved Steam Waves
                    _buildCurvedSteam(offsetX: -18, delay: 0.0),
                    _buildCurvedSteam(offsetX: 0, delay: 0.3),
                    _buildCurvedSteam(offsetX: 18, delay: 0.6),

                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 3,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Daisy Brew",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Crafting comfort in every cup.",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => OnboardingScreen1()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4E37),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Start Brewing",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedSteam({required double offsetX, required double delay}) {
    return AnimatedBuilder(
      animation: _steamController!,
      builder: (context, child) {
        final value = (_steamController!.value + delay) % 1.0;

        return Transform.translate(
          offset: Offset(offsetX, -70 - (value * 50)),
          child: Opacity(
            opacity: 1 - value,
            child: CustomPaint(
              size: const Size(30, 60),
              painter: SteamPainter(),
            ),
          ),
        );
      },
    );
  }
}

class SteamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width / 2, size.height);

    path.cubicTo(
      size.width * 0.2,
      size.height * 0.75,
      size.width * 0.8,
      size.height * 0.5,
      size.width * 0.4,
      size.height * 0.25,
    );

    path.cubicTo(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.05,
      size.width * 0.5,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
