import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nabtati/models/comment_model.dart';
import 'package:nabtati/models/reply_model.dart';
import 'package:nabtati/services/Comment_Service.dart';
import 'package:nabtati/community/reply_card.dart';

class RepliesSheet extends StatelessWidget {
  final String postId;
  final CommentModel comment;

  const RepliesSheet({
    super.key,
    required this.postId,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final controller = TextEditingController();
    final CommentService commentService = CommentService();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6, // يبدأ 60%
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'الردود',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),

              /// 🔥 الردود (Scrollable)
              Expanded(
                child: StreamBuilder<List<ReplyModel>>(
                  stream: commentService.getReplies(
                    postId,
                    comment.id,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final replies = snapshot.data!;

                    if (replies.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد ردود بعد',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: replies.length,
                      itemBuilder: (context, index) {
                        return ReplyCard(
                          reply: replies[index],
                          postId: postId,
                          commentId: comment.id,
                          currentUid: uid,
                        );
                      },
                    );
                  },
                ),
              ),

              /// ✍️ الإدخال
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'اكتب ردًا...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;

                          commentService.addReply(
                            postId: postId,
                            commentId: comment.id,
                            userId: uid,
                            text: text,
                          );

                          controller.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
