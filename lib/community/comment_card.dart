import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'Replies_BottomSheet.dart';
import 'package:nabtati/services/Comment_Service.dart';

class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final String postId;
  final String currentUid;

  const CommentCard({
    super.key,
    required this.comment,
    required this.postId,
    required this.currentUid,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  AppUser? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final u = await UserService().getUser(widget.comment.userId);
    if (mounted) {
      setState(() => user = u);
    }
  }



  @override
  Widget build(BuildContext context) {
    final isLiked =
    widget.comment.likes.contains(widget.currentUid);

    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                user!.photoUrl.isNotEmpty ? NetworkImage(user!.photoUrl) : null,
            child: user!.photoUrl.isEmpty
                ? const Icon(Icons.person, size: 18)
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// الاسم + حذف
                  Row(
                    children: [
                      Text(
                        user!.name,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                        if (widget.comment.userId == widget.currentUid)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (value) async {
                              if (value != 'delete') return;

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('حذف التعليق'),
                                  content: const Text('هل أنت متأكد من حذف هذا التعليق؟'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: const Text('إلغاء'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text(
                                        'حذف',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              await CommentService().deleteComment(
                                postId: widget.postId,
                                commentId: widget.comment.id,
                                uid: widget.comment.userId,
                              );
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                    SizedBox(width: 8),
                                    Text('حذف'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.comment.text,
                    style: GoogleFonts.tajawal(),
                  ),

                  const SizedBox(height: 6),

                  /// لايك + رد
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                      await CommentService().toggleLikeComment(
                        postId: widget.postId,
                        commentId: widget.comment.id,
                        uid: widget.currentUid,
                        isLiked: isLiked,
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(widget.comment.likes.length.toString()),
                      ],
                    ),
                      ),

                      const SizedBox(width: 16),

                        InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => RepliesSheet(
                          postId: widget.postId,
                          comment: widget.comment,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'رد',
                          style: GoogleFonts.tajawal(color: Colors.blue),
                        ),
                        const SizedBox(width: 4),
                        if (widget.comment.repliesCount > 0)
                          Text(
                            '(${widget.comment.repliesCount})',
                            style: GoogleFonts.tajawal(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
