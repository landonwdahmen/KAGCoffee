import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'footer.dart';

class BagelDiscPage extends StatelessWidget {
  const BagelDiscPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bagel Discussions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo.
            Container(
              width: MediaQuery.of(context).size.width,
              height: headerHeight,
              color: Colors.brown,
              child: Center(child: Image.asset("assets/kagtransparent.png")),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Bagels',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'This is for discussions about bagels.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Display posts in Cards.
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('topic', isEqualTo: 'Bagels')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final posts = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    final Map<String, dynamic> data = post.data() as Map<String, dynamic>;
                    final List<dynamic> likedBy = data.containsKey('likedBy')
                        ? List.from(data['likedBy'])
                        : [];
                    final bool hasLiked = currentUserId != null && likedBy.contains(currentUserId);
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/indivPost',
                          arguments: {'postId': post.id},
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(12.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (data['anonymous'] == true)
                                    ? 'Anonymous'
                                    : (data['userScreenName'] ?? 'Anonymous'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['title'] ?? 'No Title',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['content'] ?? '',
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Like row (optional)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Your like button code here.
                                  const SizedBox.shrink(),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createPost');
        },
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}