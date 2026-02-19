import 'package:daisy_brew/features/auth/data/datasources/local/cart_local_datasource.dart';
import 'package:daisy_brew/features/dashboard/domain/entities/cart_item.dart';
import 'package:daisy_brew/features/dashboard/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final String token;
  final String fullName;
  final CartItem? singleItem;

  const CheckoutScreen({
    super.key,
    required this.token,
    required this.fullName,
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

  double get totalPrice {
    return CartLocalDataSource.items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  List<CartItem> get currentItems {
    if (widget.singleItem != null) {
      return [widget.singleItem!];
    } else {
      return CartLocalDataSource.items;
    }
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
                  onChanged: (value) =>
                      setState(() => timeOption = value.toString()),
                ),
                RadioListTile(
                  value: "Schedule",
                  groupValue: timeOption,
                  activeColor: Colors.brown,
                  title: const Text("Schedule Pickup"),
                  onChanged: (value) =>
                      setState(() => timeOption = value.toString()),
                ),
              ],
            ),
            if (timeOption == "Schedule") ...[
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade300,
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                    initialDate: DateTime.now(),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time == null) return;
                  setState(() {
                    scheduledDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
                child: const Text(
                  "Select Date & Time",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (scheduledDateTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Scheduled for: ${scheduledDateTime.toString()}",
                    style: const TextStyle(color: Colors.brown),
                  ),
                ),
            ],
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Order Placed Successfully!")),
            );

            if (widget.singleItem == null) {
              CartLocalDataSource.clear();
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(token: widget.token, fullName: widget.fullName),
              ),
              (route) => false,
            );
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
