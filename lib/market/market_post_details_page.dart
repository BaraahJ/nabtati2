import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/market_post_model.dart';
import '../../models/comment_model.dart';
import '../../services/market_comment_service.dart';
import 'market_comment_card.dart';



class MarketPostDetailsPage extends StatefulWidget {
  final MarketPostModel post;

  const MarketPostDetailsPage({
    super.key,
    required this.post,
  });

  @override
  State<MarketPostDetailsPage> createState() =>
      _MarketPostDetailsPageState();
}

class _MarketPostDetailsPageState extends State<MarketPostDetailsPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final controller = TextEditingController();
  final MarketCommentService service = MarketCommentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الإعلان')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (widget.post.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(widget.post.images.first),
                  ),
                const SizedBox(height: 12),
                Text(
                  widget.post.description,
                  style: GoogleFonts.tajawal(fontSize: 16, height: 1.7),
                ),
                const Divider(height: 30),

                const Text(
                  'التعليقات',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                StreamBuilder<List<CommentModel>>(
                  stream: service.getComments(widget.post.id),
                  builder: (context, snapshot) {
                    final comments = snapshot.data ?? [];

                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('لا يوجد تعليقات بعد'),
                      );
                    }

                    return ListView.builder(
                      itemCount: comments.length,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                       return MarketCommentCard(
                        comment: comments[i],
                        postId: widget.post.id,
                      );

                      },
                    );
                  },
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'اكتب تعليقًا...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      await service.addComment(
                        postId: widget.post.id,
                        userId: uid,
                        text: text,
                      );

                      controller.clear();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
