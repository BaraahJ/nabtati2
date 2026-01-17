import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/post_service.dart';
import 'post_details_page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  bool get isLiked => widget.post.likes.contains(currentUid);

  final UserService _userService = UserService();
  final PostService _postService = PostService();

  AppUser? _owner;

  // Colors
  static const bg = Color(0xFFF6FBF9);
  static const primary = Color(0xFF5CC6A9);
  static const secondary = Color(0xFF9AD9FF);
  static const textDark = Color(0xFF2E3A3A);
  static const textLight = Color(0xFF8FA3A3);
  static const divider = Color(0xFFE3F0ED);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUser(widget.post.ownerId);
    if (!mounted) return;
    setState(() => _owner = user);
  }
void _toggleLike() async {
  final postRef =
      FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

  if (isLiked) {
    await postRef.update({
      'likes': FieldValue.arrayRemove([currentUid]),
    });
  } else {
    await postRef.update({
      'likes': FieldValue.arrayUnion([currentUid]),
    });
  }
}



  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف البوست'),
        content: const Text('هل أنت متأكد من حذف هذا البوست؟'),
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

    await _postService.deletePost(widget.post.id);
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a')
        .format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          if (_owner != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: bg,
                  backgroundImage: _owner!.photoUrl.trim().isNotEmpty
                      ? NetworkImage(_owner!.photoUrl)
                      : null,
                  child: _owner!.photoUrl.trim().isEmpty
                      ? Icon(Icons.person, color: primary)
                      : null,
                ),

                const SizedBox(width: 12),

                // Name & time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _owner!.name,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(widget.post.createdAt),
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ⋮ MENU (only owner)
                if (widget.post.ownerId == currentUid)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: textLight,
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') _deletePost();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
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

          const SizedBox(height: 16),

          /// CONTENT
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.post.content,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  height: 1.6,
                  color: textDark,
                ),
              ),
            ),

          /// IMAGE
          if (widget.post.imageUrl.trim().isNotEmpty)
            GestureDetector(
              onTap: () {
                // Navigate to a new page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailsPage(post: widget.post),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 5),
          Container(height: 1, color: divider),
          const SizedBox(height: 5),


          /// ACTIONS
          Row(
            children: [
              // LIKE
              InkWell(
                onTap: _toggleLike,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? Colors.red.withOpacity(0.08)
                        : bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            isLiked ? Colors.red : textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(widget.post.likes.length.toString()),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // COMMENTS
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PostDetailsPage(post: widget.post),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: secondary),
                      const SizedBox(width: 6),
                      Text(widget.post.commentsCount.toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
