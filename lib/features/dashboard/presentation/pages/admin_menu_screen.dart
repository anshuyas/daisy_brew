import 'dart:io';
import 'package:daisy_brew/features/dashboard/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/product_provider.dart';

class AdminMenuPage extends ConsumerWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Management"),
        backgroundColor: Colors.brown,
      ),
      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return Card(
              child: ListTile(
                leading: _buildProductImage(p),
                title: Text(p.name),
                subtitle: Text("Rs. ${p.price} • ${p.category}"),
                trailing: Switch(
                  value: p.isAvailable,
                  onChanged: (val) async {
                    try {
                      await ref
                          .read(productProvider.notifier)
                          .toggleAvailability(p.id);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to toggle availability'),
                        ),
                      );
                    }
                  },
                ),
                onTap: () {
                  _showProductDialog(context, ref, product: p);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
        onPressed: () {
          _showProductDialog(context, ref);
        },
      ),
    );
  }

  Widget _buildProductImage(Product p) {
    final img = p.image;
    if (img.isEmpty) {
      return Image.asset(
        'assets/images/default.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else if (img.startsWith('http')) {
      return Image.network(img, width: 50, height: 50, fit: BoxFit.cover);
    } else if (img.startsWith('assets/')) {
      return Image.asset(img, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      return Image.network(
        'http://192.168.254.50:3000/public/product_images/$img',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: product?.category ?? '',
    );
    bool isAvailable = product?.isAvailable ?? true;
    File? _pickedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Available'),
                    Switch(
                      value: isAvailable,
                      onChanged: (val) => setState(() => isAvailable = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: Text(
                    _pickedImage == null
                        ? (product != null ? 'Change Image' : 'Pick Image')
                        : 'Image Selected',
                  ),
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setState(() => _pickedImage = File(picked.path));
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (_pickedImage != null)
                  Image.file(_pickedImage!, height: 100, fit: BoxFit.cover)
                else if (product != null)
                  Image.network(product.image, height: 100, fit: BoxFit.cover),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final price = int.tryParse(priceController.text) ?? 0;
                final category = categoryController.text.trim();

                if (name.isEmpty || category.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                if (product == null && _pickedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please pick an image')),
                  );
                  return;
                }

                if (_pickedImage != null) {
                  // Upload new product with picked image
                  await ref
                      .read(productProvider.notifier)
                      .uploadProduct(
                        imageFile: _pickedImage!,
                        name: name,
                        price: price,
                        category: category,
                        isAvailable: isAvailable,
                      );
                } else if (product != null) {
                  // Update existing product without changing image
                  final updated = Product(
                    id: product.id,
                    name: name,
                    price: price,
                    category: category,
                    image: product.image,
                    isAvailable: isAvailable,
                  );
                  await ref
                      .read(productProvider.notifier)
                      .updateExistingProduct(updated);
                }

                Navigator.pop(context);
              },
              child: Text(product == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogProductImage(Product product) {
    final img = product.image;
    if (img.isEmpty) {
      return Image.asset(
        'assets/images/default.png',
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (img.startsWith('http')) {
      return Image.network(img, height: 100, fit: BoxFit.cover);
    } else if (img.startsWith('assets/')) {
      return Image.asset(img, height: 100, fit: BoxFit.cover);
    } else {
      return Image.network(
        'http://192.168.254.50:3000/public/product_images/$img',
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }
}
