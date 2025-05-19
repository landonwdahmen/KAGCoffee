import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'footer.dart';
import 'reply.dart'; // Provides ReplySection and ReplyInputPage

class IndivPostPage extends StatefulWidget {
  final String postId;
  const IndivPostPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<IndivPostPage> createState() => _IndivPostPageState();
}

class _IndivPostPageState extends State<IndivPostPage> {
  Map<String, dynamic>? postData;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    setState(() {
      postData = doc.data();
    });
  }

  int _getLikes() {
    try {
      return postData?['likes'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    final List<dynamic> likedBy = postData != null && postData!.containsKey('likedBy')
        ? List.from(postData!['likedBy'])
        : [];
    final bool hasLiked = currentUserId != null && likedBy.contains(currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        centerTitle: true,
      ),
      body: postData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(
                    child: Text(
                      "Post",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Post content & comments display.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Topic: ${postData!['topic'] ?? 'No Topic'}",
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${(postData!['anonymous'] == true) ? 'Anonymous' : (postData!['userScreenName'] ?? 'Anonymous')}",
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Title: ${postData!['title'] ?? 'No Title'}",
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Body Text: ${postData!['content'] ?? 'No content'}",
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 16),
                          // Like row with processing flag.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      hasLiked ? Icons.favorite : Icons.favorite_border,
                                      color: hasLiked ? Colors.red : null,
                                    ),
                                    onPressed: (currentUserId == null || _isProcessing)
                                        ? null
                                        : () async {
                                            setState(() {
                                              _isProcessing = true;
                                            });
                                            if (!hasLiked) {
                                              await FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(widget.postId)
                                                  .update({
                                                'likes': FieldValue.increment(1),
                                                'likedBy': FieldValue.arrayUnion([currentUserId])
                                              });
                                              setState(() {
                                                postData!['likes'] = _getLikes() + 1;
                                                (postData!['likedBy'] as List).add(currentUserId);
                                              });
                                            } else {
                                              await FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(widget.postId)
                                                  .update({
                                                'likes': FieldValue.increment(-1),
                                                'likedBy': FieldValue.arrayRemove([currentUserId])
                                              });
                                              setState(() {
                                                postData!['likes'] = _getLikes() - 1;
                                                (postData!['likedBy'] as List).remove(currentUserId);
                                              });
                                            }
                                            setState(() {
                                              _isProcessing = false;
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getLikes().toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.reply),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReplyInputPage(postId: widget.postId),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Comments display section.
                          ReplySection(postId: widget.postId),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const Footer(currentIndex: 0),
    );
  }
}