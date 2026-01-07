/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../colors.dart';
import 'package:nabtati/profile.dart';

class CommentsPage extends StatefulWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final CollectionReference postsRef =
  FirebaseFirestore.instance.collection('posts');

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final comment = {
      'userId': user.uid,
      'username': user.displayName ?? 'مستخدم',
      'text': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    final postDoc = postsRef.doc(widget.postId);

    await postDoc.update({
      'comments': FieldValue.arrayUnion([comment]),
      'commentsCount': FieldValue.increment(1),
    });

    final postSnapshot = await postDoc.get();
    final ownerId = postSnapshot['ownerId'];

    if (ownerId != user.uid) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .collection('notifications')
          .add({
        'postId': widget.postId,
        'text': '${user.displayName ?? "مستخدم"} علق على منشورك',
        'timestamp': FieldValue.serverTimestamp(),
        'seen': false,
        'type': 'comment',
      });
    }

    _commentController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightpink,
      appBar: AppBar(
        title: const Text('التعليقات', style: TextStyle(color: textColor)),
        backgroundColor: purble,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: postsRef.doc(widget.postId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final postData =
                snapshot.data!.data() as Map<String, dynamic>;
                final comments = List.from(postData['comments'] ?? []);

                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد تعليقات بعد",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                  userId: comment['userId']),
                            ),
                          );
                        },
                        child: Text(
                          comment['username'] ?? 'مستخدم',
                          style: const TextStyle(
                              color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(
                        comment['text'] ?? '',
                        style: const TextStyle(color: textColor),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: purble,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقًا...',
                      filled: true,
                      fillColor: white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: lavender),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/