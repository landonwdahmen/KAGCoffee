import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Custom formatter for credit card number: adds a space every 4 digits.
class CreditCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digitsOnly = newValue.text.replaceAll(' ', '');
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }
    String formatted = '';
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i % 4 == 0 && i != 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Custom formatter for expiration date: adds '/' after 2 digits.
class ExpDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll('/', '');
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }
    String formatted = '';
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i == 2 && digitsOnly.length > 2) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int coffeeCount = 0;
  int bagelCount = 0;
  String comments = "";

  // Prices
  final double coffeePrice = 2.99;
  final double bagelPrice = 1.99;

  // Controllers for credit card info.
  final TextEditingController _ccNumberController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Retrieve any navigation arguments.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      setState(() {
        coffeeCount = args?['coffeeCount'] ?? 0;
        bagelCount = args?['bagelCount'] ?? 0;
        comments = args?['comments'] ?? "";
      });
      _prefillPaymentInfo();
    });
  }

  // Prefill credit card info from the most recent order by this user.
 Future<void> _prefillPaymentInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where("userId", isEqualTo: user.uid)
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final lastOrder = snapshot.docs.first.data() as Map<String, dynamic>;
        print("Found last order: $lastOrder"); // Debug log.
        setState(() {
          _ccNumberController.text = lastOrder["ccNumber"] ?? "";
          _expDateController.text = lastOrder["expDate"] ?? "";
          _cvvController.text = lastOrder["cvv"] ?? "";
        });
      } else {
        print("No previous order found for user ${user.uid}.");
      }
    } catch (e) {
      print("Error pre-filling payment info: $e");
    }
  }
}

  double get coffeeTotal => coffeeCount * coffeePrice;
  double get bagelTotal => bagelCount * bagelPrice;
  double get subtotal => coffeeTotal + bagelTotal;
  double get tax => subtotal * 0.062;
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), centerTitle: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Brown header with logo.
              Container(
                width: MediaQuery.of(context).size.width,
                height: headerHeight,
                color: Colors.brown,
                child: Center(child: Image.asset("assets/kagtransparent.png")),
              ),
              const SizedBox(height: 24),
              // Form wrapping order and payment fields.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Checkout",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Black Coffee row.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_cafe, size: 40),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Black Coffee: \$${coffeeTotal.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (coffeeCount > 0) {
                                setState(() {
                                  coffeeCount--;
                                });
                              }
                            },
                          ),
                          Text("$coffeeCount", style: const TextStyle(fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                coffeeCount++;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Plain Bagel row.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/bagel.png", height: 40, width: 40),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Plain Bagel: \$${bagelTotal.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (bagelCount > 0) {
                                setState(() {
                                  bagelCount--;
                                });
                              }
                            },
                          ),
                          Text("$bagelCount", style: const TextStyle(fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                bagelCount++;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Comments display.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Text("Comments: $comments", style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 20),
                      // Credit Card Number field.
                      TextFormField(
                        controller: _ccNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CreditCardNumberFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: "Credit Card Number",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.replaceAll(' ', '').isEmpty) {
                            return 'Credit Card Number is required';
                          }
                          if (value.replaceAll(' ', '').length < 16) {
                            return 'Enter a valid 16-digit number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Exp Date and CVV fields on the same row.
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                ExpDateInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                labelText: "Exp Date",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Exp Date is required';
                                }
                                if (!value.contains('/')) {
                                  return 'Enter exp date as MM/YY';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: const InputDecoration(
                                labelText: "CVV",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'CVV is required';
                                }
                                if (value.length < 3) {
                                  return 'Enter a valid 3-digit CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Subtotal row.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Subtotal:", style: TextStyle(fontSize: 20)),
                          Text("\$${subtotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Tax row.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tax (6.2%):", style: TextStyle(fontSize: 20)),
                          Text("\$${tax.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Total row.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Confirm Order button with Firestore write.
                      SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final user = FirebaseAuth.instance.currentUser;
                              final orderData = {
                                "userId": user?.uid ?? "unknown",
                                "coffeeCount": coffeeCount,
                                "bagelCount": bagelCount,
                                "subtotal": subtotal,
                                "tax": tax,
                                "total": total,
                                "comments": comments,
                                "ccNumber": _ccNumberController.text,
                                "expDate": _expDateController.text,
                                "cvv": _cvvController.text,
                                "timestamp": FieldValue.serverTimestamp(),
                              };

                              // Get a reference to the global orders counter.
                              DocumentReference counterRef = FirebaseFirestore.instance
                                  .collection("counters")
                                  .doc("ordersCounter");
                              // Create a new document reference for the order.
                              DocumentReference orderDocRef = FirebaseFirestore.instance
                                  .collection("orders")
                                  .doc();

                              await FirebaseFirestore.instance
                                  .runTransaction((transaction) async {
                                DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
                                int currentCount;
                                
                                // If the counter doesn't exist, initialize it to 0; first order gets "00000".
                                if (!counterSnapshot.exists) {
                                  currentCount = 0;
                                  transaction.set(counterRef, {'orderCount': 1});
                                } else {
                                  currentCount = counterSnapshot.get('orderCount') as int;
                                  transaction.update(counterRef, {'orderCount': currentCount + 1});
                                }

                                // Format the order id as a 5-digit number.
                                String orderId = currentCount.toString().padLeft(5, '0');

                                // Add the order id to the orderData.
                                orderData["orderId"] = orderId;
                                // Set the new order document using the orderData.
                                transaction.set(orderDocRef, orderData);
                              });

                              Navigator.pushReplacementNamed(context, '/orderPlaced', arguments: orderData);
                            }
                          },
                          child: const Text(
                            "Confirm Order",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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