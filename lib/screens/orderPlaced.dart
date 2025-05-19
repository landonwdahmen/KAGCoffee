import 'package:flutter/material.dart';
import 'footer.dart';

class OrderPlacedPage extends StatelessWidget {
  const OrderPlacedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text("Order Placed"), centerTitle: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Brown header with logo.
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.15,
                color: Colors.brown,
                child: Center(
                  child: Image.asset("assets/kagtransparent.png"),
                ),
              ),
              const SizedBox(height: 24),
              // Center the order details.
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: orderData == null
                      ? const Text("No order details available.",
                          style: TextStyle(fontSize: 18))
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Order Placed Successfully!",
                              style:
                                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text("Order ID: ${orderData['orderId']}",
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 10),
                            // Combined row for Coffee & Bagel counts.
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_cafe, size: 40),
                                const SizedBox(width: 8),
                                Text("Coffee: ${orderData['coffeeCount']}",
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 16),
                                Image.asset("assets/bagel.png",
                                    height: 40, width: 40),
                                const SizedBox(width: 8),
                                Text("Bagel: ${orderData['bagelCount']}",
                                    style: const TextStyle(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                                "Subtotal: \$${(orderData['subtotal'] as double).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 18)),
                            Text(
                                "Tax (6.2%): \$${(orderData['tax'] as double).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 18)),
                            Text(
                                "Total: \$${(orderData['total'] as double).toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            Text("Comments: ${orderData['comments']}",
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 2),
    );
  }
}