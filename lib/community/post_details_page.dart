import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Replies_BottomSheet.dart';
import 'package:nabtati/community/comment_card.dart';
class PostDetailsPage extends StatefulWidget {
  final PostModel post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();
  final CommentService _commentService = CommentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التفاصيل', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // البوست نفسه
                if (widget.post.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(widget.post.imageUrl),
                  ),
                const SizedBox(height: 12),
                Text(
                  widget.post.content,
                  style: GoogleFonts.tajawal(fontSize: 16, height: 1.7),
                ),
                const Divider(height: 30),

                // التعليقات
                const Text(
                  'التعليقات',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                StreamBuilder<List<CommentModel>>(
                  stream: _commentService.getComments(widget.post.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final comments = snapshot.data ?? [];

                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('لا يوجد تعليقات بعد'),
                      );
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return CommentCard(
                          comment: comment,
                          postId: widget.post.id,
                          currentUid: uid,
                        );

                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // حقل إضافة تعليق جديد
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقًا...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendComment,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _commentService.addComment(
      postId: widget.post.id,
      userId: uid,
      text: text,
    );

    _controller.clear();
  }
}
