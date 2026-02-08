import 'dart:async';
import 'package:daisy_brew/features/dashboard/presentation/pages/cart_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:dio/dio.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/header_widget.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String fullName;

  const HomeScreen({super.key, required this.token, required this.fullName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  int bottomNavIndex = 0;

  ShakeDetector? _shakeDetector;
  StreamSubscription<dynamic>? _proximitySubscription;

  bool isDarkMode = false;
  DateTime? _lastProximityTrigger;

  String? profileImageUrl;

  final List<String> categories = [
    'Coffee',
    'Matcha',
    'Smoothies',
    'Bubble Tea',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (event) => _logoutUser(),
      shakeThresholdGravity: 2.7,
    );

    try {
      _proximitySubscription = ProximitySensor.events.listen((event) {
        if (event > 0) _toggleThemeWithCooldown();
      });
    } catch (e) {
      debugPrint("Proximity sensor error: $e");
    }
  }

  Future<void> _fetchProfilePicture() async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.token}';
      final baseUrl = 'http://192.168.254.200:3000/api/v1';
      final response = await dio.get('$baseUrl/profile');

      if (response.data != null && response.data['profilePicture'] != null) {
        final imageUrl =
            'http://192.168.254.200:3000/public/profile_pictures/${response.data['profilePicture']}';

        setState(() {
          profileImageUrl = imageUrl;
        });

        debugPrint("Profile image fetched: $imageUrl");
      }
    } catch (e) {
      debugPrint('Failed to fetch profile picture: $e');
    }
  }

  void _toggleThemeWithCooldown() {
    final now = DateTime.now();
    if (_lastProximityTrigger != null &&
        now.difference(_lastProximityTrigger!).inSeconds < 2)
      return;

    _lastProximityTrigger = now;
    if (!mounted) return;

    setState(() => isDarkMode = !isDarkMode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode ? "Dark Mode Activated" : "Light Mode Activated",
        ),
      ),
    );
  }

  void _logoutUser() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out due to phone shake")),
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _proximitySubscription?.cancel();
    super.dispose();
  }

  void _onCategoryTap(int index) {
    setState(() => selectedCategoryIndex = index);
  }

  void _onCartTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen()),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == bottomNavIndex) return;

    setState(() => bottomNavIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(token: widget.token),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationScreen(token: widget.token),
        ),
      );
    } else if (index == 3) {
      // Navigate to ProfileScreen with callback to update profile picture
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            token: widget.token,
            fullName: widget.fullName,
            initialProfilePicture: profileImageUrl,
            onProfileUpdated: (newUrl) {
              debugPrint("New profile image URL received: $newUrl");

              setState(() {
                profileImageUrl = newUrl; // update profile picture immediately
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF6EBDD),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.black54,
        currentIndex: bottomNavIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Order History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              onCartTap: _onCartTap,
              fullName: widget.fullName,
              profilePictureUrl: profileImageUrl, // pass the image URL
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    categories.length,
                    (index) => CategoryChipWidget(
                      label: categories[index],
                      selected: selectedCategoryIndex == index,
                      onTap: () => _onCategoryTap(index),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                  children: const [
                    ProductCardWidget(
                      name: 'Cappuccino',
                      price: 'Rs. 250',
                      imagePath: 'assets/images/cappucino.jpg',
                    ),
                    ProductCardWidget(
                      name: 'Americano',
                      price: 'Rs. 150',
                      imagePath: 'assets/images/americano.jpg',
                    ),
                    ProductCardWidget(
                      name: 'Espresso',
                      price: 'Rs. 100',
                      imagePath: 'assets/images/espresso.jpg',
                    ),
                    ProductCardWidget(
                      name: 'Latte',
                      price: 'Rs. 200',
                      imagePath: 'assets/images/latte.jpg',
                    ),
                    ProductCardWidget(
                      name: 'Iced Machhiato',
                      price: 'Rs. 295',
                      imagePath: 'assets/images/iced macchiato.jpg',
                    ),
                    ProductCardWidget(
                      name: 'Ristretto',
                      price: 'Rs. 125',
                      imagePath: 'assets/images/ristretto.webp',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
