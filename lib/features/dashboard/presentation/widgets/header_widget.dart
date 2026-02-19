import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onCartTap;
  final String fullName;
  final String? profilePictureUrl;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  const HeaderWidget({
    super.key,
    required this.onCartTap,
    required this.fullName,
    this.profilePictureUrl,
    this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF8C7058),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile picture
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: profilePictureUrl != null
                    ? NetworkImage(profilePictureUrl!)
                    : null,
                child: profilePictureUrl == null
                    ? const Icon(Icons.person, color: Colors.brown)
                    : null,
              ),
              GestureDetector(
                onTap: onCartTap,
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Good to see you, $fullName!',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
