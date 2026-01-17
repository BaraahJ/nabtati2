import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/comment_model.dart';
import '../../models/reply_model.dart';
import '../../services/market_comment_service.dart';
import 'market_reply_card.dart';

class MarketRepliesSheet extends StatefulWidget {
  final String postId;
  final CommentModel comment;

  const MarketRepliesSheet({
    super.key,
    required this.postId,
    required this.comment,
  });

  @override
  State<MarketRepliesSheet> createState() => _MarketRepliesSheetState();
}

class _MarketRepliesSheetState extends State<MarketRepliesSheet> {
  final controller = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final service = MarketCommentService();

  @override
@override
Widget build(BuildContext context) {
  return FractionallySizedBox(
    heightFactor: 0.66, // 👈 ثلثين الشاشة
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          /// خط صغير فوق (شكل جميل)
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),

          /// الردود
          Expanded(
            child: StreamBuilder<List<ReplyModel>>(
              stream: service.getReplies(
                widget.postId,
                widget.comment.id,
              ),
              builder: (context, snapshot) {
                final replies = snapshot.data ?? [];

                if (replies.isEmpty) {
                  return const Center(
                    child: Text('لا يوجد ردود بعد'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: replies.length,
                  itemBuilder: (_, i) {
                   return MarketReplyCard(
                  key: ValueKey(replies[i].id), // 🔥 مهم
                  reply: replies[i],
                  postId: widget.postId,
                  commentId: widget.comment.id,
                );

                  },
                );
              },
            ),
          ),

          /// إضافة رد
          SafeArea(
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
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      await service.addReply(
                        postId: widget.postId,
                        commentId: widget.comment.id,
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
    ),
  );
}

}
