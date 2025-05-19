import 'package:flutter/material.dart';
import 'footer.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _coffeeCount = 0;
  int _bagelCount = 0;
  final TextEditingController _commentsController = TextEditingController();

  double getTotalPrice() {
    return _coffeeCount * 2.99 + _bagelCount * 1.99;
  }

  void _incrementCoffee() {
    setState(() {
      _coffeeCount++;
    });
  }

  void _decrementCoffee() {
    if (_coffeeCount > 0) {
      setState(() {
        _coffeeCount--;
      });
    }
  }

  void _incrementBagel() {
    setState(() {
      _bagelCount++;
    });
  }

  void _decrementBagel() {
    if (_bagelCount > 0) {
      setState(() {
        _bagelCount--;
      });
    }
  }

  void _placeOrder() {
    if (_coffeeCount == 0 && _bagelCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please order at least one item.")),
      );
      return;
    }
    double total = getTotalPrice();
    String comments = _commentsController.text.trim();
    List<String> orderItems = [];
    if (_coffeeCount > 0) {
      orderItems.add("$_coffeeCount Black Coffee(s) (\$${(2.99 * _coffeeCount).toStringAsFixed(2)})");
    }
    if (_bagelCount > 0) {
      orderItems.add("$_bagelCount Plain Bagel(s) (\$${(1.99 * _bagelCount).toStringAsFixed(2)})");
    }
    String orderSummary = orderItems.join(" & ");
    String message = "Order placed: $orderSummary\nTotal: \$${total.toStringAsFixed(2)}";
    if (comments.isNotEmpty) {
      message += "\nComments: $comments";
    };
    
    

     // In _placeOrder(), replace the existing navigation call with:
    Navigator.pushReplacementNamed(context, '/checkout', arguments: {
      'coffeeCount': _coffeeCount,
      'bagelCount': _bagelCount,
      'comments': comments,
    });
    // Clear the order details (if desired)
    setState(() {
      _coffeeCount = 0;
      _bagelCount = 0;
    });
    _commentsController.clear();
  
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Increase the header font size by using copyWith on titleLarge.
    final TextStyle coffeeHeaderStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26);
    final TextStyle bagelHeaderStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26);

    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(title: const Text("Order"), centerTitle: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Full-width header with brown background and logo.
              Container(
                width: MediaQuery.of(context).size.width,
                height: headerHeight,
                color: Colors.brown,
                child: Center(
                  child: Image.asset("assets/kagtransparent.png"),
                ),
              ),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  "Place Order",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Order form sections.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Coffee Section Header (enlarged).
                    Center(
                      child: Text(
                        "Coffee",
                        style: coffeeHeaderStyle,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Black Coffee row.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_cafe, size: 40),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Black Coffee (\$2.99 each)",
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _decrementCoffee,
                            ),
                            Text("$_coffeeCount", style: const TextStyle(fontSize: 20)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _incrementCoffee,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 2),
                    const SizedBox(height: 20),
                    // Bagel Section Header (enlarged).
                    Center(
                      child: Text(
                        "Bagel",
                        style: bagelHeaderStyle,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Plain Bagel row with new bagel icon from assets.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/bagel.png",
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Plain Bagel (\$1.99 each)",
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _decrementBagel,
                            ),
                            Text("$_bagelCount", style: const TextStyle(fontSize: 20)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _incrementBagel,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Border between bagel and comment box.
                    const SizedBox(height: 20),
                    const Divider(thickness: 2),
                    const SizedBox(height: 30),
                    // Comments field.
                    TextFormField(
                      controller: _commentsController,
                      decoration: const InputDecoration(
                        labelText: "Add Comments (optional)",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    // Place Order button.
                    Center(
                      child: SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800000), // Maroon background.
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: _placeOrder,
                          child: const Text(
                            "Place Order",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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