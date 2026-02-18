import 'package:daisy_brew/features/auth/data/datasources/local/cart_local_datasource.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/cart_item.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 0;
  int? selectedSize;
  bool? isHot;
  int? sugarLevel;
  String? milk;
  bool _imageVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EBDD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top image container
              SizedBox(
                height: 260,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: InvertedArcClipper(),
                      child: Container(
                        height: 200,
                        color: const Color(0xFFB7A89B),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(widget.product.image, height: 150),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Quantity selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _qtyButton(Icons.remove, () {
                    if (quantity > 1) setState(() => quantity--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  _qtyButton(Icons.add, () {
                    setState(() => quantity++);
                  }),
                ],
              ),

              const SizedBox(height: 24),

              _sectionTitle('Size'),
              _sizeSelector(),

              _sectionTitle('Temperature'),
              _temperatureSelector(),

              _sectionTitle('Sugar'),
              _sugarSelector(),

              _sectionTitle('Milk'),
              _milkSelector(),

              const SizedBox(height: 24),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        'Add to cart',
                        Colors.brown,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        'Buy Now',
                        Colors.brown,
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.brown.shade300,
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _sizeSelector() {
    final sizes = [20.0, 26.0, 32.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return _optionBox(
          icon: Icons.local_cafe,
          iconSize: sizes[index],
          selected: selectedSize == index,
          onTap: () => setState(() => selectedSize = index),
        );
      }),
    );
  }

  Widget _temperatureSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_tempChip('Hot', true), _tempChip('Iced', false)],
    );
  }

  Widget _tempChip(String label, bool value) {
    final bool selected = isHot == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: Colors.brown.shade300,
        onSelected: (_) => setState(() => isHot = value),
      ),
    );
  }

  Widget _sugarSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final selected = sugarLevel == index;

        return GestureDetector(
          onTap: () => setState(() => sugarLevel = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? Colors.brown.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  index + 1,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(Icons.circle, size: 7),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _milkSelector() {
    final milks = ['Oat milk', 'Soy milk', 'Almond milk'];

    return Wrap(
      spacing: 12,
      alignment: WrapAlignment.center,
      children: milks.map((item) {
        return ChoiceChip(
          label: Text(item),
          selected: milk == item,
          selectedColor: Colors.brown.shade300,
          onSelected: (_) => setState(() => milk = item),
        );
      }).toList(),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(text),
        selected: selected,
        selectedColor: Colors.brown.shade300,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _optionBox({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    double iconSize = 24,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected ? Colors.brown.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.brown.shade300 : Colors.grey.shade400,
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color bg, Color fg) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        if (quantity == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select quantity')),
          );
          return;
        }

        if (selectedSize == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please select size')));
          return;
        }

        if (isHot == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select temperature')),
          );
          return;
        }

        CartLocalDataSource.addItem(
          CartItem(
            product: widget.product,
            quantity: quantity,
            size: selectedSize,
            isHot: isHot,
            sugar: sugarLevel,
            milk: milk,
          ),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to cart')));

        Navigator.pop(context);
      },
      child: Text(text),
    );
  }
}

class InvertedArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
      size.width / 2,
      size.height - 180,
      size.width,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
