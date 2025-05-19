import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in.');
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception('User data not found in Firestore.');
    }
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final userData = snapshot.data!;
          final firstName = userData['firstName'] ?? 'User';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Brown header with centered logo.
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: headerHeight,
                  color: Colors.brown,
                  child: Center(
                    child: Image.asset("assets/kagtransparent.png"),
                  ),
                ),
                const SizedBox(height: 20),
                // Home header text.
                const Center(
                  child: Text(
                    'Home',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 35),
                // Greeting with user's first name.
                Center(
                  child: Text(
                    'Hello, $firstName!',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 30),
                // Welcome message.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Welcome to KAG's Coffee and Bagels!",
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                // Discussion Topics header.
                const Center(
                  child: Text(
                    'Discussion Topics:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                // Stack of buttons.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 250, // Fixed width for a narrower button.
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/coffeeDisc');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5DC), // Same as background.
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 1), // Added border
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          icon: const Icon(Icons.local_cafe_outlined, size: 24, color: Colors.black,),
                          label: const Text(
                            "Coffee",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/bagelDisc');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5DC),
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 1), // Added border
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          icon: Image.asset("assets/bagel.png", height: 24, width: 24),
                          label: const Text(
                            "Bagels",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/genDisc');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5DC),
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 1), // Added border
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          icon: const Icon(Icons.people_alt_outlined, size: 24, color: Colors.black,),
                          label: const Text(
                            "General",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/createPost');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5DC),
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 1), // Added border
                            minimumSize: const Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline_outlined, size: 24, color: Colors.black,),
                          label: const Text(
                            "Create Post",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Additional content can be added here.
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const Footer(currentIndex: 0),
    );
  }
}