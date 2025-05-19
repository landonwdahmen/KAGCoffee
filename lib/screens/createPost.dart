import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'footer.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _selectedTopic = "Coffee"; // Default topic
  bool _postAnonymously = false; // Checkbox state

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    String title = _titleController.text.trim();
    String content = _postController.text.trim();
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        String userScreenName = 'Anonymous';
        
        // If the user is NOT posting anonymously, fetch screen name from users collection.
        if (currentUser != null && !_postAnonymously) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          if (userDoc.exists) {
            userScreenName =
                (userDoc.data() as Map<String, dynamic>)['screenName'] ?? 'Anonymous';
          }
        }
        
        await FirebaseFirestore.instance.collection('posts').add({
          'topic': _selectedTopic,
          'title': title,
          'content': content,
          'anonymous': _postAnonymously,
          'timestamp': FieldValue.serverTimestamp(),
          'userScreenName': userScreenName,
          'userId': currentUser?.uid, // Added user id here
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post submitted!')),
        );
        _postController.clear();
        _titleController.clear();
        setState(() {
          _postAnonymously = false;
        });
        // Navigate to appropriate discussion page.
        if (_selectedTopic == "Coffee") {
          Navigator.pushReplacementNamed(context, '/coffeeDisc');
        } else if (_selectedTopic == "Bagels") {
          Navigator.pushReplacementNamed(context, '/bagelDisc');
        } else if (_selectedTopic == "General") {
          Navigator.pushReplacementNamed(context, '/genDisc');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit post.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Brown header with logo
            Container(
              width: MediaQuery.of(context).size.width,
              height: headerHeight,
              color: Colors.brown,
              child: Center(
                child: Image.asset("assets/kagtransparent.png"),
              ),
            ),
            const SizedBox(height: 20),
            // Create Post header
            const Center(
              child: Text(
                'Create Post',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Topic field (label and dropdown on one row)
                  Row(
                    children: [
                      const Text(
                        "Topic:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedTopic,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedTopic = newValue!;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          ),
                          items: const [
                            DropdownMenuItem(child: Text("Coffee"), value: "Coffee"),
                            DropdownMenuItem(child: Text("Bagels"), value: "Bagels"),
                            DropdownMenuItem(child: Text("General"), value: "General"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Title field (label and text field on one row)
                  Row(
                    children: [
                      const Text(
                        "Title:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 138),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: "Title",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Post content field
                  TextField(
                    controller: _postController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Enter your post here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Checkbox for anonymous post (centered)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _postAnonymously,
                        onChanged: (bool? value) {
                          setState(() {
                            _postAnonymously = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        "Post anonymously",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Submit Post",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 0),
    );
  }
}