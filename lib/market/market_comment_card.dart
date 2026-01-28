import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/market_comment_service.dart';
import 'market_replies_sheet.dart';

class MarketCommentCard extends StatefulWidget {
  final CommentModel comment;
  final String postId;

  const MarketCommentCard({
    super.key,
    required this.comment,
    required this.postId,
  });

  @override
  State<MarketCommentCard> createState() => _MarketCommentCardState();
}

class _MarketCommentCardState extends State<MarketCommentCard> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final service = MarketCommentService();

  AppUser? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final u = await UserService().getUser(widget.comment.userId);
    if (mounted) setState(() => user = u);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox();

    final isLiked = widget.comment.likes.contains(currentUid);

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
                      if (widget.comment.userId == currentUid)
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (_) async {
                            await service.deleteComment(
                              postId: widget.postId,
                              commentId: widget.comment.id,
                              uid: widget.comment.userId,
                            );
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.red, size: 18),
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
                          await service.toggleLikeComment(
                            postId: widget.postId,
                            commentId: widget.comment.id,
                            uid: currentUid,
                            isLiked: isLiked,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isLiked ? Colors.red : Colors.grey,
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
                            builder: (_) => MarketRepliesSheet(
                              postId: widget.postId,
                              comment: widget.comment,
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'رد',
                              style: GoogleFonts.tajawal(
                                color: Colors.blue,
                              ),
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
