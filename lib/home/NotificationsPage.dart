import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/garden_plant_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "الإشعارات",
            style: GoogleFonts.tajawal(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: const Color(0xFF527D75),
            labelColor: const Color(0xFF527D75),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "تفاعلات المجتمع"),
              Tab(text: "مواعيد العناية"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CommunityNotificationsList(),
            GardenTasksNotificationsList(),
          ],
        ),
      ),
    );
  }
}

// --- 1. قسم تفاعلات المجتمع (جلب اسم المستخدم من مجموعة users) ---
class CommunityNotificationsList extends StatelessWidget {
  const CommunityNotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      // نستخدم collectionGroup لجلب كل التعليقات من كل المنشورات
      stream: FirebaseFirestore.instance.collectionGroup('comments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("خطأ في التحميل"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        final now = DateTime.now();

        // فلترة: تعليقات اليوم فقط + ليست تعليقاتي الشخصية
        final todayNotifs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          return createdAt != null &&
              data['userId'] != myUid &&
              createdAt.day == now.day &&
              createdAt.month == now.month &&
              createdAt.year == now.year;
        }).toList();

        if (todayNotifs.isEmpty) return Center(child: Text("لا توجد تفاعلات جديدة اليوم", style: GoogleFonts.tajawal()));

        return ListView.builder(
          itemCount: todayNotifs.length,
          itemBuilder: (context, index) {
            final data = todayNotifs[index].data() as Map<String, dynamic>;
            final String userId = data['userId'] ?? "";
            final DateTime time = (data['createdAt'] as Timestamp).toDate();

            // جلب اسم المستخدم من مجموعة الـ users الأساسية
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnap) {
                String userName = "مستخدم";
                if (userSnap.hasData && userSnap.data!.exists) {
                  userName = (userSnap.data!.data() as Map<String, dynamic>)['name'] ?? "مستخدم";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.comment)),
                    title: RichText(
                      text: TextSpan(
                        style: GoogleFonts.tajawal(color: Colors.black),
                        children: [
                          TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: " علّق على منشورك"),
                        ],
                      ),
                    ),
                    trailing: Text(DateFormat('HH:mm').format(time), style: const TextStyle(fontSize: 10)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- 2. قسم مواعيد العناية (جلب اسم النبتة من مجموعة garden) ---
class GardenTasksNotificationsList extends StatelessWidget {
  const GardenTasksNotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text("يرجى تسجيل الدخول"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('doneAt', isNull: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("خطأ في التحميل"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final now = DateTime.now();
        final tasks = snapshot.data!.docs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final date = (d['dueDate'] as Timestamp?)?.toDate();
          return date != null && date.day == now.day && date.month == now.month && date.year == now.year;
        }).toList();

        if (tasks.isEmpty) return Center(child: Text("لا توجد مهام عناية اليوم 🌱", style: GoogleFonts.tajawal()));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final taskData = tasks[index].data() as Map<String, dynamic>;
            final String plantId = taskData['plantId'] ?? "";
            final String type = taskData['type'] ?? 'watering';

            // جلب اسم النبتة من مجموعة garden الخاصة بالمستخدم
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('garden') // حسب كود الـ GardenService الخاص بكِ
                  .doc(plantId)
                  .get(),
              builder: (context, plantSnap) {
                String plantName = "نبتتك";
                if (plantSnap.hasData && plantSnap.data!.exists) {
                  plantName = (plantSnap.data!.data() as Map<String, dynamic>)['name'] ?? "نبتتك";
                }

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(_getIcon(type), color: _getColor(type)),
                    title: Text(
                      "${_getTaskVerb(type)} نبتة $plantName",
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("راجع صفحة المهام", style: GoogleFonts.tajawal(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => tasks[index].reference.update({'doneAt': FieldValue.serverTimestamp()}),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getTaskVerb(String type) {
    if (type == 'watering') return "ري";
    if (type == 'fertilizing') return "تسميد";
    return "تقليم";
  }

  IconData _getIcon(String type) {
    if (type == 'watering') return Icons.water_drop;
    if (type == 'fertilizing') return Icons.eco;
    return Icons.cut;
  }

  Color _getColor(String type) {
    if (type == 'watering') return Colors.blue;
    if (type == 'fertilizing') return Colors.orange;
    return Colors.green;
  }
}