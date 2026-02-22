import 'dart:async';
import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/product_detail_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/cart_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/header_widget.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String fullName;
  final String email;

  const HomeScreen({
    super.key,
    required this.token,
    required this.fullName,
    required this.email,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  int bottomNavIndex = 0;

  String currentFullName = '';

  ShakeDetector? _shakeDetector;

  String? profileImageUrl;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<String> categories = [
    'Coffee',
    'Matcha',
    'Smoothies',
    'Bubble Tea',
  ];

  final Map<String, List<Product>> categoryProducts = {
    'Coffee': [
      Product(
        id: 'coffee1',
        name: 'Cappuccino',
        image: 'assets/images/cappucino.jpg',
        price: 250,
      ),
      Product(
        id: 'coffee2',
        name: 'Americano',
        image: 'assets/images/americano.jpg',
        price: 150,
      ),
      Product(
        id: 'coffee3',
        name: 'Espresso',
        image: 'assets/images/espresso.jpg',
        price: 100,
      ),
      Product(
        id: 'coffee4',
        name: 'Latte',
        image: 'assets/images/latte.jpg',
        price: 200,
      ),
      Product(
        id: 'coffee5',
        name: 'Iced Macchiato',
        image: 'assets/images/iced macchiato.jpg',
        price: 295,
      ),
      Product(
        id: 'coffee6',
        name: 'Ristretto',
        image: 'assets/images/ristretto.webp',
        price: 125,
      ),
    ],

    'Matcha': [
      Product(
        id: 'matcha1',
        name: 'Matcha Latte',
        image: 'assets/images/matcha-latte.avif',
        price: 350,
      ),
      Product(
        id: 'matcha2',
        name: 'Strawberry Matcha',
        image: 'assets/images/strawberry-matcha.png',
        price: 380,
      ),
      Product(
        id: 'matcha3',
        name: 'Coconut Matcha Cloud',
        image: 'assets/images/coconut-matcha-cloud.jpg',
        price: 390,
      ),
      Product(
        id: 'matcha4',
        name: 'Vanilla Matcha',
        image: 'assets/images/vanilla-matcha.jpg',
        price: 390,
      ),
      Product(
        id: 'matcha5',
        name: 'Matcha Hot Chocolate',
        image: 'assets/images/matcha-hot-choc.jpg',
        price: 370,
      ),
      Product(
        id: 'matcha6',
        name: 'Honey Matcha',
        image: 'assets/images/honey-matcha.jpg',
        price: 380,
      ),
      Product(
        id: 'matcha7',
        name: 'Mango Matcha Latte',
        image: 'assets/images/mango-matcha-latte.webp',
        price: 395,
      ),
    ],

    'Smoothies': [
      Product(
        id: 'smoothie1',
        name: 'Blueberry Smoothie',
        image: 'assets/images/blueberry-smoothie.webp',
        price: 250,
      ),
      Product(
        id: 'smoothie2',
        name: 'Strawberry Smoothie',
        image: 'assets/images/strawberry-smoothie.png',
        price: 250,
      ),
      Product(
        id: 'smoothie3',
        name: 'Banana Smoothie',
        image: 'assets/images/banana-smoothie.webp',
        price: 200,
      ),
      Product(
        id: 'smoothie4',
        name: 'Mango Smoothie',
        image: 'assets/images/mango-smoothie.png',
        price: 230,
      ),
      Product(
        id: 'smoothie5',
        name: 'Watermelon Smoothie',
        image: 'assets/images/watermelon-smoothie.png',
        price: 240,
      ),
      Product(
        id: 'smoothie6',
        name: 'Pineapple Smoothie',
        image: 'assets/images/pineapple-smoothie.png',
        price: 260,
      ),
      Product(
        id: 'smoothie7',
        name: 'Cherry Smoothie',
        image: 'assets/images/cherry-smoothie.avif',
        price: 270,
      ),
    ],

    'Bubble Tea': [
      Product(
        id: 'bubble1',
        name: 'Taro BubbleTea',
        image: 'assets/images/taro-bubble.jpg',
        price: 220,
      ),
      Product(
        id: 'bubble2',
        name: 'Chocolate BubbleTea',
        image: 'assets/images/chocolate-bubble.png',
        price: 220,
      ),
      Product(
        id: 'bubble3',
        name: 'Mango BubbleTea',
        image: 'assets/images/mango-bubble.png',
        price: 220,
      ),
      Product(
        id: 'bubble4',
        name: 'Strawberry BubbleTea',
        image: 'assets/images/strawberry-bubble.png',
        price: 220,
      ),
      Product(
        id: 'bubble5',
        name: 'HoneyDew BubbleTea',
        image: 'assets/images/honeydew-bubble.jpg',
        price: 220,
      ),
      Product(
        id: 'bubble6',
        name: 'Coconut BubbleTea',
        image: 'assets/images/coconut-bubble.webp',
        price: 220,
      ),
      Product(
        id: 'bubble7',
        name: 'Matcha BubbleTea',
        image: 'assets/images/matcha-bubble.jpg',
        price: 220,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
    _loadProfilePictureFromPrefs();

    currentFullName = widget.fullName;

    // Shake to logout
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (event) => _logoutUser(),
      shakeThresholdGravity: 2.7,
    );
  }

  Future<void> _fetchProfilePicture() async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.token}';
      final baseUrl = 'http://192.168.254.10:3000/api/v1';
      final response = await dio.get('$baseUrl/profile');

      if (response.data != null && response.data['profilePicture'] != null) {
        final imageUrl =
            'http://192.168.254.10:3000/public/profile_pictures/${response.data['profilePicture']}';

        if (mounted && (profileImageUrl == null || profileImageUrl!.isEmpty)) {
          setState(() => profileImageUrl = imageUrl);
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch profile picture: $e');
    }
  }

  Future<void> _loadProfilePictureFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('${widget.email}-profile_picture');

    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        profileImageUrl = savedUrl;
      });
    }
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
    _searchController.dispose();
    _shakeDetector?.stopListening();
    super.dispose();
  }

  void _onCategoryTap(int index) {
    setState(() => selectedCategoryIndex = index);
    searchQuery = '';
    _searchController.clear();
  }

  void _onCartTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          token: widget.token,
          fullName: widget.fullName,
          email: widget.email,
        ),
      ),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            token: widget.token,
            fullName: currentFullName,
            email: widget.email,
            initialProfilePicture: profileImageUrl,
            onProfileUpdated: (newUrl, {String? updatedName}) async {
              setState(() {
                profileImageUrl = newUrl;
                if (updatedName != null) currentFullName = updatedName;
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts =
        categoryProducts[categories[selectedCategoryIndex]] ?? [];

    final currentProducts = allProducts.where((product) {
      return product.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
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
              fullName: currentFullName,
              profilePictureUrl: profileImageUrl,
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() => searchQuery = value);
              },
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
                child: currentProducts.isEmpty
                    ? const Center(
                        child: Text(
                          "No drinks found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        itemCount: currentProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          final product = currentProducts[index];

                          return ProductCardWidget(
                            name: product.name,
                            price: 'Rs. ${product.price}',
                            imagePath: product.image,
                            onAddTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: product,
                                    category: categories[selectedCategoryIndex],
                                    token: widget.token,
                                    fullName: currentFullName,
                                    email: widget.email,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
