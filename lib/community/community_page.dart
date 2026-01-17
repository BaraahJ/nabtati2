import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/post_service.dart';
import 'post_card.dart';
import '../market/market_page.dart';
import 'add_post_page.dart';
import '../market/add_market_post_page.dart';
import 'package:nabtati/models/post_model.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int selectedIndex = 0;
  final PostService _postService = PostService();

  // Soft pastel colors
  static const bg = Color(0xFFF6FBF9);
  static const primary = Color(0xFF5CC6A9); // mint
  static const secondary = Color(0xFF9AD9FF); // baby blue
  static const textDark = Color(0xFF2E3A3A);
  static const textLight = Color(0xFF8FA3A3);
  static const divider = Color(0xFFE3F0ED);

  void _onAddPressed() {
    if (selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPostPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddMarketPostPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            // Header area with Stack
            Stack(
              children: [
                // صورة الخلفية
                Image.asset(
                  'assets/images/aaa.jpeg',
                  width: double.infinity,
                  height: 220, // ارتفاع أكبر للصورة
                  fit: BoxFit.cover,
                ),
                
                // التابات في آخر الصورة
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTab(
                            icon: Icons.people_rounded,
                            title: "المجتمع",
                            isSelected: selectedIndex == 0,
                            onTap: () => setState(() => selectedIndex = 0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTab(
                            icon: Icons.store_rounded,
                            title: "المتجر",
                            isSelected: selectedIndex == 1,
                            onTap: () => setState(() => selectedIndex = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: selectedIndex == 0
                    ? _buildPostsTab(key: const ValueKey(1))
                    : MarketPage(key: const ValueKey(2)),
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 229, 151, 243),
                const Color.fromARGB(255, 228, 153, 203).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onAddPressed,
              borderRadius: BorderRadius.circular(20),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color.fromARGB(255, 40, 87, 95) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color.fromARGB(255, 16, 106, 106) : const Color.fromARGB(255, 72, 79, 79),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color.fromARGB(255, 16, 106, 106) : const Color.fromARGB(255, 88, 92, 92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab({Key? key}) {
    return Container(
      key: key,
      color: const Color.fromARGB(255, 237, 246, 249),
      child: StreamBuilder<List<PostModel>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: const Color.fromARGB(255, 230, 206, 235),
                strokeWidth: 3,
              ),
            );
          }

          final posts = snapshot.data!;
          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 16, bottom: 90),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => PostCard(post: posts[i]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withOpacity(0.15),
                  secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 70,
              color: primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'لا توجد منشورات بعد',
            style: GoogleFonts.tajawal(
              fontSize: 22,
              color: textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'كن أول من يبدأ المحادثة!\nشارك أفكارك وتجاربك مع المجتمع',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: textLight,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}