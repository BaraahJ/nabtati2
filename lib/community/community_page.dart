import 'package:flutter/material.dart';
import '../colors.dart';
import 'add_post_page.dart';
import 'comments_page.dart';
import 'market.dart';
import 'marketpost.dart';
import 'dart:io';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _posts = [
    {
      'username': 'سارة',
      'userImage': 'https://cdn-icons-png.flaticon.com/512/1946/1946429.png',
      'content': 'نباتي الجديد كبر 🌱💚',
      'imageUrl':
          'https://images.unsplash.com/photo-1616627455361-6c8b1f43a66a?w=500',
      'likes': 3,
      'comments': 2,
    },
    {
      'username': 'ليان',
      'userImage': 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
      'content': 'كيف أقدر أعتني بالصبار؟ 🌵',
      'imageUrl': '',
      'likes': 5,
      'comments': 4,
    },
  ];

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

  //  لإضافة منشور جديد
  void _addNewPost(Map<String, dynamic> newPost) {
    setState(() {
      _posts.insert(0, newPost);
    });
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
        elevation: 6,
        shadowColor: lavender.withOpacity(0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
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

      // محتوى الصفحات
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          const MarketPage(),
        ],
      ),

      // زر الاضافة الموجود بصفحتين الماركت والمنشورات كل واحد بودي على اشي
      floatingActionButton: FloatingActionButton(
        backgroundColor: lavender,
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPostPage(onAddPost: _addNewPost),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddMarketPostPage()),
            );
          }
        },
        child: const Icon(Icons.add, color: white),
      ),
    );
  }

  // صفحة المنشورات
  Widget _buildPostsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final bool hasImage =
            post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty;

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
                // معلومات المستخدم
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(post['userImage']),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // الصورة (من الإنترنت أو من الجهاز)
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: post['imageUrl'].startsWith('http')
                        ? Image.network(post['imageUrl'])
                        : Image.file(File(post['imageUrl'])),
                  ),
                if (hasImage) const SizedBox(height: 10),

                // المحتوى
                Text(
                  post['content'],
                  style: const TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 10),

                // أيقونات التفاعل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: lavender),
                        const SizedBox(width: 5),
                        Text('${post['likes']}'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          color: lavender,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentsPage(post: post),
                              ),
                            );
                          },
                        ),
                        Text('${post['comments']}'),
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
  }
}
