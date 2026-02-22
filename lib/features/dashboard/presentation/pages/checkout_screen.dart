import 'package:daisy_brew/core/api/api_client.dart';
import 'package:daisy_brew/features/auth/data/datasources/local/cart_local_datasource.dart';
import 'package:daisy_brew/features/auth/data/datasources/local/order_local_datasource.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/cart_entity.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/order_entity.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/home_screen.dart';
import 'package:daisy_brew/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shipping_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String token;
  final String fullName;
  final String email;
  final CartItem? singleItem;

  const CheckoutScreen({
    super.key,
    required this.token,
    required this.fullName,
    required this.email,
    this.singleItem,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPayment = "Cash on Delivery";
  String orderType = "Delivery";
  String timeOption = "ASAP";
  DateTime? scheduledDateTime;

  String? shippingAddress;
  bool isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadShippingAddress();
  }

  Future<void> _loadShippingAddress() async {
    setState(() => isLoadingAddress = true);

    final prefs = await SharedPreferences.getInstance();
    final localKey = '${widget.email}-shipping_address';

    try {
      final localAddress = prefs.getString(localKey);
      if (localAddress != null && localAddress.isNotEmpty) {
        setState(() {
          shippingAddress = localAddress;
          isLoadingAddress = false;
        });
        return;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${widget.token}';

      final response = await dio.get(
        "http://192.168.254.10:3000/api/v1/users/profile",
      );

      final user =
          response.data['user'] ?? response.data['data'] ?? response.data;
      final backendAddress = user['shippingAddress'];

      if (backendAddress != null && backendAddress.isNotEmpty) {
        setState(() {
          shippingAddress = backendAddress;
        });
        await prefs.setString(localKey, backendAddress);
      }
    } catch (e) {
      debugPrint("Checkout address load error: $e");
    } finally {
      setState(() => isLoadingAddress = false);
    }
  }

  List<CartItem> get currentItems {
    if (widget.singleItem != null) {
      return [widget.singleItem!];
    } else {
      return CartLocalDataSource.items;
    }
  }

  double get totalPrice {
    return currentItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = currentItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF6EBDD),
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ORDER SUMMARY
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...cartItems.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Image.asset(
                    item.product.image,
                    width: 45,
                    fit: BoxFit.contain,
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(
                    "Qty: ${item.quantity} • Rs. ${item.product.price}",
                  ),
                  trailing: Text(
                    "Rs. ${item.product.price * item.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rs. $totalPrice",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// SHIPPING ADDRESS
            const Text(
              "Shipping Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            isLoadingAddress
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shippingAddress ?? "No address added",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async {
                            final updatedAddress = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShippingAddressScreen(
                                  token: widget.token,
                                  currentEmail: widget.email,
                                ),
                              ),
                            );

                            if (updatedAddress != null &&
                                updatedAddress.isNotEmpty) {
                              setState(() {
                                shippingAddress = updatedAddress;
                              });
                            } else {
                              _loadShippingAddress();
                            }
                          },
                          child: const Text("Edit Address"),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 30),

            /// ORDER TYPE
            const Text(
              "Order Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _orderTypeChip("Delivery")),
                const SizedBox(width: 12),
                Expanded(child: _orderTypeChip("Pickup")),
              ],
            ),

            const SizedBox(height: 24),

            /// TIME OPTION
            const Text(
              "Pickup Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile(
                  value: "ASAP",
                  groupValue: timeOption,
                  activeColor: Colors.brown,
                  title: const Text("ASAP (Now - 15 mins)"),
                  onChanged: (value) {
                    setState(() {
                      timeOption = value.toString();
                      scheduledDateTime = null;
                    });
                  },
                ),
                RadioListTile(
                  value: "Schedule",
                  groupValue: timeOption,
                  activeColor: Colors.brown,
                  title: const Text("Schedule Pickup"),
                  onChanged: (value) async {
                    setState(() {
                      timeOption = value.toString();
                    });
                    // Show date & time picker
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: scheduledDateTime ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );

                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          scheduledDateTime ??
                              DateTime.now().add(const Duration(minutes: 15)),
                        ),
                      );

                      if (selectedTime != null) {
                        setState(() {
                          scheduledDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                if (timeOption == "Schedule" && scheduledDateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Pickup scheduled for: ${scheduledDateTime!.toLocal()}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            /// PAYMENT METHOD
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _paymentOption("Cash on Delivery"),
                _paymentOption("eSewa"),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      /// PLACE ORDER BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            if (currentItems.isEmpty) return;

            if (orderType == "Delivery" &&
                (shippingAddress == null || shippingAddress!.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please add shipping address first"),
                ),
              );
              return;
            }

            final orderNumber = DateTime.now().millisecondsSinceEpoch
                .toString();

            final total = currentItems.fold<double>(
              0,
              (sum, item) => sum + (item.product.price * item.quantity),
            );

            final productsForApi = currentItems
                .map(
                  (item) => {
                    'product': item.product.id,
                    'quantity': item.quantity,
                    'price': item.product.price,
                  },
                )
                .toList();

            try {
              final apiClient = ApiClient();
              final orderApi = OrderRemoteDatasource(apiClient);

              await orderApi.createOrder(
                products: productsForApi,
                totalPrice: total,
              );
              final order = Order(
                orderNumber: orderNumber,
                dateTime: DateTime.now(),
                items: currentItems,
                status: "Confirmed",
                total: total,
              );

              await OrderLocalDataSource.addOrder(order);

              if (widget.singleItem == null) {
                CartLocalDataSource.clear();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Order Placed Successfully!")),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    token: widget.token,
                    fullName: widget.fullName,
                    email: widget.email,
                  ),
                ),
                (route) => false,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to place order: $e")),
              );
            }
          },
          child: const Text(
            "Place Order",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _paymentOption(String method) {
    return RadioListTile(
      value: method,
      groupValue: selectedPayment,
      activeColor: Colors.brown,
      onChanged: (value) => setState(() => selectedPayment = value.toString()),
      title: Text(method),
    );
  }

  Widget _orderTypeChip(String type) {
    final selected = orderType == type;
    return ChoiceChip(
      label: Text(type),
      selected: selected,
      selectedColor: Colors.brown.shade300,
      onSelected: (_) => setState(() => orderType = type),
    );
  }
}
