import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'footer.dart'; // Ensure this file exists and exports your Footer widget.

/// Displays the list of comments for a post.
class ReplySection extends StatefulWidget {
  final String postId;
  const ReplySection({Key? key, required this.postId}) : super(key: key);

  @override
  State<ReplySection> createState() => _ReplySectionState();
}

class _ReplySectionState extends State<ReplySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comments",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.postId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final comments = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final commentDoc = comments[index];
                final commentData =
                    commentDoc.data() as Map<String, dynamic>;
                final int commentLikes = commentData['likes'] ?? 0;
                final List<dynamic> commentLikedBy =
                    commentData.containsKey('likedBy')
                        ? List.from(commentData['likedBy'])
                        : [];
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                final bool hasLiked = currentUserId != null &&
                    commentLikedBy.contains(currentUserId);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Comment text and user screen name.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(commentData['text'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              "By ${commentData['userScreenName'] ?? 'Unknown'}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Like button & count.
                      Row(
                        children: [
                          Text(commentLikes.toString()),
                          IconButton(
                            icon: Icon(
                              hasLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: hasLiked ? Colors.red : null,
                            ),
                            onPressed: () async {
                              if (currentUserId == null) return;
                              final commentRef = FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.postId)
                                  .collection('comments')
                                  .doc(commentDoc.id);
                              if (!hasLiked) {
                                await commentRef.update({
                                  'likes': FieldValue.increment(1),
                                  'likedBy': FieldValue.arrayUnion([currentUserId])
                                });
                              } else {
                                await commentRef.update({
                                  'likes': FieldValue.increment(-1),
                                  'likedBy': FieldValue.arrayRemove([currentUserId])
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// A page for entering a new comment, which shows the post info, header, input area, and the comments section.
class ReplyInputPage extends StatefulWidget {
  final String postId;
  const ReplyInputPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<ReplyInputPage> createState() => _ReplyInputPageState();
}

class _ReplyInputPageState extends State<ReplyInputPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _postAnonymously = false;

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String screenName;
    if (_postAnonymously) {
      screenName = 'Anonymous';
    } else {
      // Fetch the user's screenName from Firestore.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      screenName = userDoc.exists && userDoc.data()!.containsKey('screenName')
          ? userDoc.data()!['screenName']
          : (currentUser.displayName ?? currentUser.email ?? 'User');
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'text': _commentController.text.trim(),
      'userId': currentUser.uid,
      'userScreenName': screenName,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'likedBy': [],
    });
    _commentController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reply"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            // "Reply" word below the header (centered).
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  "Reply",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Post information section.
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final postData =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Topic: ${postData['topic'] ?? 'No Topic'}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Title: ${postData['title'] ?? 'No Title'}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Body Text: ${postData['content'] ?? 'No Content'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
            // Input section for the comment.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write your comment here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Checkbox to toggle anonymous posting.
                  Row(
                    children: [
                      Checkbox(
                        value: _postAnonymously,
                        onChanged: (value) {
                          setState(() {
                            _postAnonymously = value ?? false;
                          });
                        },
                      ),
                      const Text("Comment anonymously"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000), // Maroon color.
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _postComment,
                    child: const Text("Post Comment"),
                  ),
                ],
              ),
            ),
            // Comments section.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReplySection(postId: widget.postId),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(currentIndex: 0),
    );
  }
}