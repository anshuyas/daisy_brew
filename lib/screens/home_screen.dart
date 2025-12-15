import 'package:flutter/material.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  int bottomNavIndex = 0;

  final List<String> categories = [
    'Coffee',
    'Matcha',
    'Smoothies',
    'Bubble Tea',
  ];

  void _onCategoryTap(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  void _onCartTap() {}

  void _onBottomNavTap(int index) {
    setState(() {
      bottomNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EBDD),
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
            HeaderWidget(onCartTap: _onCartTap),
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
                    ProductCardWidget(name: 'Cappuccino', price: 'Rs. 250'),
                    ProductCardWidget(name: 'Americano', price: 'Rs. 150'),
                    ProductCardWidget(name: 'Espresso', price: 'Rs. 100'),
                    ProductCardWidget(name: 'Latte', price: 'Rs. 200'),
                    ProductCardWidget(name: 'Iced Machiato', price: 'Rs. 295'),
                    ProductCardWidget(name: 'Ristretto', price: 'Rs. 125'),
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
