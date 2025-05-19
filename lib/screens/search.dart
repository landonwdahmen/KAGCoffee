import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'footer.dart';
import 'indivPost.dart'; // IndivPostPage is defined here

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  
  @override
  State<SearchPage> createState() => _SearchPageState();
}
  
class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    // Fetch all posts from Firestore.
    final snapshot = await FirebaseFirestore.instance.collection('posts').get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        })
        .where((post) {
          final content = (post['content'] ?? "").toString().toLowerCase();
          final title = (post['title'] ?? "").toString().toLowerCase();
          return _searchText.isEmpty ||
                 content.contains(_searchText) ||
                 title.contains(_searchText);
        })
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Brown header with Kag logo.
            SizedBox(
              height: headerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.brown),
                  Center(child: Image.asset("assets/kagtransparent.png")),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Header text that says "Search"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  "Search",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Search field.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Enter search text...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search results.
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!;
                if (posts.isEmpty) {
                  return const Center(child: Text("No posts found."));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text("Title: ${post['title'] ?? 'No Title'}"),
                        subtitle: Text("Body: ${post['content'] ?? 'No Content'}"),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/indivPost',
                            arguments: {'postId': post['id']},
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 1),
    );
  }
}