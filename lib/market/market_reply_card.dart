import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/reply_model.dart';
import '../../models/user_model.dart';
import '../../services/market_comment_service.dart';
import '../../services/user_service.dart';

class MarketReplyCard extends StatefulWidget {
  final ReplyModel reply;
  final String postId;
  final String commentId;

  const MarketReplyCard({
    super.key,
    required this.reply,
    required this.postId,
    required this.commentId,
  });

  @override
  State<MarketReplyCard> createState() => _MarketReplyCardState();
}

class _MarketReplyCardState extends State<MarketReplyCard> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final MarketCommentService service = MarketCommentService();
  AppUser? user;

  late bool isLiked;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    _loadUser();
    isLiked = widget.reply.likes.contains(uid);
    likesCount = widget.reply.likes.length;
  }

  void _loadUser() async {
    final u = await UserService().getUser(widget.reply.userId);
    if (mounted) setState(() => user = u);
  }

  void _toggleLike() async {
    final newValue = !isLiked;

    setState(() {
      isLiked = newValue;
      likesCount += newValue ? 1 : -1;
    });

    await service.toggleReplyLike(
      postId: widget.postId,
      commentId: widget.commentId,
      replyId: widget.reply.id,
      uid: uid,
      isLiked: !newValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox();

    return Dismissible(
      key: ValueKey(widget.reply.id),
      direction: widget.reply.userId == uid
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white, ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('حذف الرد'),
                content: const Text('هل تريد حذف هذا الرد؟'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text(
                      'حذف',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        service.deleteReply(
          postId: widget.postId,
          commentId: widget.commentId,
          replyId: widget.reply.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Avatar
            CircleAvatar(
              radius: 14,
              backgroundImage: user!.photoUrl.isNotEmpty
                  ? NetworkImage(user!.photoUrl)
                  : null,
              child: user!.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 14)
                  : null,
            ),
            const SizedBox(width: 8),

            /// 💬 Bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                 color: const Color.fromARGB(255, 237, 238, 237),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color.fromARGB(255, 174, 174, 174),
                    style: BorderStyle.solid, // أخف للماركيت
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// Name + Like
                    Row(
                      children: [
                        Text(
                          user!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isLiked
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          likesCount.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// Text
                    Text(
                      widget.reply.text,
                      textAlign: TextAlign.right,
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
