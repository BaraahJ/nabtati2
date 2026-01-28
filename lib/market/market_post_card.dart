import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/market_post_model.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/market_service.dart';
import 'market_post_details_page.dart';

class MarketPostCard extends StatefulWidget {
  final MarketPostModel post;

  const MarketPostCard({super.key, required this.post});

  @override
  State<MarketPostCard> createState() => _MarketPostCardState();
}

class _MarketPostCardState extends State<MarketPostCard> {
  AppUser? user;
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    likesCount = widget.post.likes.length;
    isLiked = widget.post.likes.contains(currentUid);
  }

  void _loadUser() async {
    final u = await UserService().getUser(widget.post.userId);
    if (mounted) setState(() => user = u);
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });

    await MarketService().toggleLike(
      postId: widget.post.id,
      uid: currentUid!,
      isLiked: !isLiked,
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListTile(
        leading: const Icon(Icons.delete, color: Colors.red),
        title: const Text('حذف الإعلان'),
        onTap: () async {
          Navigator.pop(context);
          await MarketService().deletePost(widget.post.id, widget.post.userId); 
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

   /* final date = widget.post.createdAt != null
        ? DateFormat('dd MMM yyyy').format(widget.post.createdAt!)
        : '';*/

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 👤 HEADER
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user!.photoUrl.isNotEmpty
                      ? NetworkImage(user!.photoUrl)
                      : null,
                  child: user!.photoUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    /*  Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),*/
                    ],
                  ),
                ),

                if (widget.post.userId == currentUid)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _showOptions,
                  ),
              ],
            ),
          ),

          /// 🏷️ FLAGS (CITY + CATEGORY)

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: Row(
    children: [
      /// FLAGS
      Expanded(
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _flag(widget.post.city, Icons.location_on, Colors.blue),
            _flag(widget.post.category, Icons.local_florist, const Color.fromARGB(255, 249, 96, 214)),
          ],
        ),
      ),

      /// PRICE
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 155, 189, 188).withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.attach_money,
                size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              widget.post.price,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),


          const SizedBox(height: 10),

          /// 🌱 PRODUCT NAME
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.title,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// 📝 DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.post.description,
              style: GoogleFonts.tajawal(height: 1.6),
            ),
          ),

          const SizedBox(height: 10),

          /// 🖼️ IMAGES
         if (widget.post.images.isNotEmpty)
          SizedBox(
            height: 230,
            child: PageView.builder(
              itemCount: widget.post.images.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MarketPostDetailsPage(post: widget.post),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.post.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
            
          ),

const SizedBox(height: 10),
          /// ❤️ ACTIONS
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: Row(
    children: [
      // LIKE
      InkWell(
        onTap: _toggleLike,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isLiked ? Colors.red.withOpacity(0.08) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                likesCount.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
              builder: (_) => MarketPostDetailsPage(post: widget.post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade100.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: Colors.green.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.post.commentsCount.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),


          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _flag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
