import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import 'auth/auth_service.dart';
import 'user_service.dart';
import 'user_model.dart';
import 'cloudinary_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final user = FirebaseAuth.instance.currentUser;

  AppUser? appUser;

  bool isUploadingImage = false;
  String selectedTab = "posts";

  late AnimationController _tabController;

  // lazy loading
  static const int pageSize = 9;
  DocumentSnapshot? lastPostDoc;
  DocumentSnapshot? lastMarketDoc;
  bool loadingPosts = false;
  bool loadingMarket = false;

  List<DocumentSnapshot> userPosts = [];
  List<DocumentSnapshot> marketPosts = [];

  final adminEmail = "admin@example.com";

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _tabController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _loadUser();
    _loadPosts();
    _loadMarket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= LOAD USER =================
  Future<void> _loadUser() async {
    if (user == null) return;
    final data = await _userService.getUser(user!.uid);
    if (!mounted) return;
    setState(() => appUser = data);
  }

  // ================= CLOUDINARY IMAGE =================
  Future<void> _changeProfileImage() async {
    if (user == null) return;

    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isUploadingImage = true);

    final imageUrl =
        await CloudinaryService.uploadProfile(File(picked.path));

    await _userService.updatePhoto(
      uid: user!.uid,
      photoUrl: imageUrl,
    );

    await _loadUser();
    setState(() => isUploadingImage = false);
  }

  // ================= EDIT PROFILE =================
  void _openEditProfileDialog() {
  if (appUser == null) return; // safety check

  final nameController = TextEditingController(text: appUser!.name);
  final bioController = TextEditingController(text: appUser!.bio);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("تعديل الملف الشخصي"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await _changeProfileImage();
                  // بعد تغيير الصورة نحدث الـ controllers ونعيد تحميل user
                  await _loadUser();
                },
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: appUser!.photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(appUser!.photoUrl)
                      : null,
                  child: appUser!.photoUrl.isEmpty
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "الاسم",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "البايو",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(), // فقط يسكر الدايالوق
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              // تحديث الاسم والبايو
              await _userService.updateNameBio(
                uid: user!.uid,
                name: nameController.text.trim(),
                bio: bioController.text.trim(),
              );

              await _loadUser(); // refresh

              Navigator.of(dialogContext).pop(); // يغلق الدايالوق فقط
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    ),
  );
}



  // ================= FIRESTORE LAZY =================
  Future<void> _loadPosts() async {
    if (loadingPosts || user == null) return;
    setState(() => loadingPosts = true);

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastPostDoc != null) {
      query = query.startAfterDocument(lastPostDoc!);
    }

    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      lastPostDoc = snap.docs.last;
      userPosts.addAll(snap.docs);
    }

    setState(() => loadingPosts = false);
  }

  Future<void> _loadMarket() async {
    if (loadingMarket || user == null) return;
    setState(() => loadingMarket = true);

    Query query = FirebaseFirestore.instance
        .collection('market')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastMarketDoc != null) {
      query = query.startAfterDocument(lastMarketDoc!);
    }

    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      lastMarketDoc = snap.docs.last;
      marketPosts.addAll(snap.docs);
    }

    setState(() => loadingMarket = false);
  }

  // ================= EMPTY STATE =================
  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= GRID =================
  Widget _buildGrid(List<DocumentSnapshot> items, VoidCallback onLoadMore) {
    if (items.isEmpty) {
      return _emptyState("لا يوجد عناصر بعد");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (_, i) {
        if (i == items.length) {
          onLoadMore();
          return const Center(child: CircularProgressIndicator());
        }
        return CachedNetworkImage(
          imageUrl: items[i]['imageUrl'],
          fit: BoxFit.cover,
        );
      },
    );
  }

  // ================= LOGOUT  =================
  void _logout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد؟"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (!mounted) return;
              context.go('/login');
            },
            child: const Text("تسجيل الخروج",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= SETTINGS =================
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("الإشعارات"),
            onTap: openAppSettings,
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("فيدباك"),
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: adminEmail,
                queryParameters: {'subject': 'Feedback'},
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("أخبر أصدقائك"),
            onTap: () => Share.share("جرب هذا التطبيق 🌱"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (appUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
  children: [
    const SizedBox(height: 40),
    Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: const Icon(Icons.menu, size: 32),
        onPressed: _showSettings,
      ),
    ),

    // ===== HEADER =====
    GestureDetector(
      onTap: _openEditProfileDialog,
      child: CircleAvatar(
        radius: 75,
        backgroundImage: appUser!.photoUrl.isNotEmpty
            ? CachedNetworkImageProvider(appUser!.photoUrl)
            : null,
        child: appUser!.photoUrl.isEmpty
            ? const Icon(Icons.person, size: 60)
            : null,
      ),
    ),

    const SizedBox(height: 16),
    Text(appUser!.name,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

    Text('@${appUser!.username}',
        style: const TextStyle(color: Colors.grey)),

    if (appUser!.bio.isNotEmpty)
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(appUser!.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
      ),

    OutlinedButton(
      onPressed: _openEditProfileDialog,
      child: const Text("تعديل الملف الشخصي"),
    ),

    const SizedBox(height: 20),

    // ===== TABS =====
    Row(
      children: [
        _tabButton("بوستاتي", "posts"),
        _tabButton("الماركت", "market"),
      ],
    ),

    AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: selectedTab == "posts"
          ? _buildGrid(userPosts, _loadPosts)
          : _buildGrid(marketPosts, _loadMarket),
    ),
  ],
)

        ),
      ),
    );
  }

  Widget _tabButton(String title, String value) {
    final selected = selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.green : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
