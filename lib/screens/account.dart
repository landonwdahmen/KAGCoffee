import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'footer.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? userData;

  Future<void> _loadAccountInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          userData = data;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _updateProfile() {
    Navigator.pushNamed(context, '/editAccount');
  }

  @override
  Widget build(BuildContext context) {
    final double logoHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(title: const Text("Account"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo section with maroon header behind the logo.
              SizedBox(
                height: logoHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.brown),
                    Center(child: Image.asset("assets/kagtransparent.png")),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Center(
                child: Text(
                  'Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              // Account details box.
              if (userData != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Screen Name: ${userData!['screenName'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Phone: ${userData!['phone'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Email: ${userData!['email'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 30),
              // Row of two buttons: Update Profile and Logout.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF800000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF800000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Two-column section for Posts and Orders.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Posts Column.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Posts',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              // List of user's posts.
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                      "An error occurred.",
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final posts = snapshot.data!.docs;
                                  if (posts.isEmpty) {
                                    return const Text(
                                      "No posts yet.",
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: posts.length,
                                    itemBuilder: (context, index) {
                                      var post = posts[index];
                                      final Map<String, dynamic> data = post.data() as Map<String, dynamic>;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/indivPost',
                                            arguments: {'postId': post.id},
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              data['title'] ?? 'No Title',
                                              style: const TextStyle(fontSize: 18),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                        width: 1,
                      ),
                      // Orders Column.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'Orders',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('orders')
                                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                      "An error occurred.",
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final orders = snapshot.data!.docs;
                                  if (orders.isEmpty) {
                                    return const Text(
                                      "No orders yet.",
                                      style: TextStyle(fontSize: 16),
                                    );
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final order = orders[index].data() as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Order ID: ${order['orderId']}",
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              "Total: \$${(order['total'] as double).toStringAsFixed(2)}",
                                              style: const TextStyle(fontSize: 16),
                                              textAlign: TextAlign.center,
                                            ),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 3),
    );
  }
}