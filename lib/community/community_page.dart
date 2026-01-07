/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../colors.dart';
import 'add_post_page.dart';
import 'comments_page.dart';
import 'market.dart';
import 'marketpost.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'المجتمع',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 200, 210, 185).withOpacity(0.9),
                const Color.fromARGB(255, 235, 213, 237).withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: textColor,
          indicatorColor: lavender,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'المنشورات'),
            Tab(text: 'السوق'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          const MarketPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lavender,
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPostPage(
                  onPostAdded: () {
                    setState(() {});
                  },
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMarketPostPage(),
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: white),
      ),
    );
  }

  Widget _buildPostsTab() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return const Center(
            child: Text(
              "لا توجد منشورات بعد",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;

            final hasImage =
                data['imageUrl'] != null && data['imageUrl'] != '';

            final userId = currentUser?.uid;
            final likedBy = List<String>.from(data['likedBy'] ?? []);
            final isLiked =
                userId != null && likedBy.contains(userId);

            return Card(
              color: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shadowColor: lavender.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage:
                          NetworkImage(data['userImage']),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          data['username'] ?? 'مستخدم',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(data['imageUrl']),
                      ),
                    if (hasImage) const SizedBox(height: 10),

                    Text(
                      data['content'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: lavender,
                              ),
                              onPressed: userId == null
                                  ? null
                                  : () async {
                                if (isLiked) {
                                  await post.reference.update({
                                    'likedBy':
                                    FieldValue.arrayRemove(
                                        [userId]),
                                    'likesCount':
                                    FieldValue.increment(-1),
                                  });
                                } else {
                                  await post.reference.update({
                                    'likedBy':
                                    FieldValue.arrayUnion(
                                        [userId]),
                                    'likesCount':
                                    FieldValue.increment(1),
                                  });
                                }
                              },
                            ),
                            Text('${data['likesCount'] ?? 0}'),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.comment_outlined,
                                color: lavender,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommentsPage(
                                            postId: post.id),
                                  ),
                                );
                              },
                            ),
                            Text(
                                '${data['commentsCount'] ?? 0}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}*/