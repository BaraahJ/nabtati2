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

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../services/cloudinary_service.dart';

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

  static const int pageSize = 9;
  DocumentSnapshot? lastPostDoc;
  DocumentSnapshot? lastMarketDoc;
  bool loadingPosts = false;
  bool loadingMarket = false;

  List<DocumentSnapshot> userPosts = [];
  List<DocumentSnapshot> marketPosts = [];

  final adminEmail = "admin@example.com";

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

  Future<void> _loadUser() async {
    if (user == null) return;
    final data = await _userService.getUser(user!.uid);
    if (!mounted) return;
    setState(() => appUser = data);
  }

  Future<void> _changeProfileImage() async {
    if (user == null) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isUploadingImage = true);
    final imageUrl = await CloudinaryService.uploadProfile(File(picked.path));
    await _userService.updatePhoto(uid: user!.uid, photoUrl: imageUrl);
    await _loadUser();
    setState(() => isUploadingImage = false);
  }

  void _openEditProfileDialog() {
    if (appUser == null) return;
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
                  decoration: const InputDecoration(hintText: "الاسم", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: "البايو", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("إلغاء")),
            TextButton(
              onPressed: () async {
                await _userService.updateNameBio(
                  uid: user!.uid,
                  name: nameController.text.trim(),
                  bio: bioController.text.trim(),
                );
                await _loadUser();
                Navigator.pop(dialogContext);
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FETCH AND SHOW DYNAMIC PRIVACY POLICY =================
  void _showPrivacyPolicy() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF527D75))),
    );

    try {
      var doc = await FirebaseFirestore.instance.collection('app_info').doc('policies').get();
      String policyText = "لا توجد سياسات متاحة حالياً.";
      
      if (doc.exists && doc.data() != null) {
        policyText = doc.data()!['text'] ?? "النص فارغ.";
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); 
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.privacy_tip, color: Color(0xFF527D75)),
                SizedBox(width: 10),
                Text("سياسة الخصوصية"),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "نحن في تطبيق نبتتي 🌱 نحترم خصوصيتك ونلتزم بحمايتها:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    policyText,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const Text("استخدامك للتطبيق يعني موافقتك على هذه السياسات."),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("فهمت ذلك", style: TextStyle(color: Color(0xFF527D75), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      debugPrint("Error fetching policy: $e");
    }
  }

  // ================= SETTINGS BOTTOM SHEET =================
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blueGrey),
              title: const Text("الإشعارات"),
              onTap: () {
                Navigator.pop(context);
                openAppSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.blueGrey),
              title: const Text("فيدباك"),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri(scheme: 'mailto', path: adminEmail, queryParameters: {'subject': 'Feedback'});
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.blueGrey),
              title: const Text("سياسة الخصوصية"),
              onTap: () {
                Navigator.pop(context);
                _showPrivacyPolicy();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blueGrey),
              title: const Text("أخبر أصدقائك"),
              onTap: () {
                Navigator.pop(context);
                Share.share("جرب تطبيق نبتتي 🌱 للعناية بنباتاتك وتجربة الماركت!");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPosts() async {
    if (loadingPosts || user == null) return;
    setState(() => loadingPosts = true);
    Query query = FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: user!.uid).orderBy('createdAt', descending: true).limit(pageSize);
    if (lastPostDoc != null) query = query.startAfterDocument(lastPostDoc!);
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
    Query query = FirebaseFirestore.instance.collection('market').where('userId', isEqualTo: user!.uid).orderBy('createdAt', descending: true).limit(pageSize);
    if (lastMarketDoc != null) query = query.startAfterDocument(lastMarketDoc!);
    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      lastMarketDoc = snap.docs.last;
      marketPosts.addAll(snap.docs);
    }
    setState(() => loadingMarket = false);
  }

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

  Widget _buildGrid(List<DocumentSnapshot> items, VoidCallback onLoadMore) {
    if (items.isEmpty) return _emptyState("لا يوجد عناصر بعد");
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemBuilder: (_, i) {
        if (i == items.length) {
          onLoadMore();
          return const Center(child: CircularProgressIndicator());
        }
        return CachedNetworkImage(imageUrl: items[i]['imageUrl'], fit: BoxFit.cover);
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (mounted) context.go('/login');
            },
            child: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (appUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(icon: const Icon(Icons.menu, size: 32), onPressed: _showSettings),
              ),
              GestureDetector(
                onTap: _openEditProfileDialog,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: appUser!.photoUrl.isNotEmpty ? CachedNetworkImageProvider(appUser!.photoUrl) : null,
                  child: appUser!.photoUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(appUser!.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text('@${appUser!.username}', style: const TextStyle(color: Colors.grey)),
              if (appUser!.bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(appUser!.bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                ),
              OutlinedButton(onPressed: _openEditProfileDialog, child: const Text("تعديل الملف الشخصي")),
              const SizedBox(height: 20),
              Row(
                children: [
                  _tabButton("بوستاتي", "posts"),
                  _tabButton("الماركت", "market"),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: selectedTab == "posts" ? _buildGrid(userPosts, _loadPosts) : _buildGrid(marketPosts, _loadMarket),
              ),
            ],
          ),
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
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: selected ? Colors.green : Colors.transparent, width: 3))),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selected ? Colors.green : Colors.grey)),
        ),
      ),
    );
  }
}