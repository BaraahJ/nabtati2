import 'package:flutter/material.dart';
import '../models/reply_model.dart';
import '../models/user_model.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';


class ReplyCard extends StatefulWidget {
  final ReplyModel reply;
  final String postId;
  final String commentId;
  final String currentUid;

  const ReplyCard({
    super.key,
    required this.reply,
    required this.postId,
    required this.commentId,
    required this.currentUid,
  });

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  AppUser? user;
  late bool isLiked;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    _loadUser();
    isLiked = widget.reply.isLikedBy(widget.currentUid);
    likesCount = widget.reply.likes.length;
  }

  void _loadUser() async {
    final u = await UserService().getUser(widget.reply.userId);
    if (mounted) setState(() => user = u);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox();

    return Dismissible(
      key: ValueKey(widget.reply.id),
      direction: widget.reply.userId == widget.currentUid
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
confirmDismiss: (_) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // ⛔ يمنع إغلاق الصفحة بالغلط
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('حذف الرد'),
        content: const Text('هل تريد حذف هذا الرد؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // ✅ إغلاق الديالوج فقط
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true); // ✅ موافق
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  return result == true; // 🔥 مهم جدًا
},

 onDismissed: (_) {
  CommentService().deleteReply(
    postId: widget.postId,
    commentId: widget.commentId,
    replyId: widget.reply.id,
  );
},

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage:
                  user!.photoUrl.isNotEmpty ? NetworkImage(user!.photoUrl) : null,
              child: user!.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 14)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(user!.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () async {
                            final newValue = !isLiked;

                            setState(() {
                              isLiked = newValue;
                              likesCount += newValue ? 1 : -1;
                            });

                            await CommentService().toggleReplyLike(
                              postId: widget.postId,
                              commentId: widget.commentId,
                              replyId: widget.reply.id,
                              uid: widget.currentUid,
                              isLiked: !newValue,
                            );
                          },
                        ),
                        Text(likesCount.toString()),
                      ],
                    ),
                    Text(widget.reply.text, textAlign: TextAlign.right),
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
