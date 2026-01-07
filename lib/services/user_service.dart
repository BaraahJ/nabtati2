import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  // 🔹 جلب المستخدم مرة وحدة
  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc.data()!);
  }

  // 🔹 Stream للمستخدم (Real-time)
  Stream<AppUser?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc.data()!);
    });
  }
/*
  // 🔹 تحديث البايو
  Future<void> updateBio({
    required String uid,
    required String bio,
  }) async {
    await _users.doc(uid).update({
      'bio': bio,
    });
  }*/
  // 🔹 تحديث الاسم والبايو معاً
Future<void> updateNameBio({
  required String uid,
  required String name,
  required String bio,
}) async {
  await _users.doc(uid).update({
    'name': name,
    'bio': bio,
  });
}


  // 🔹 تحديث صورة البروفايل
  Future<void> updatePhoto({
    required String uid,
    required String photoUrl,
  }) async {
    await _users.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  // 🔹 إضافة نقاط
  Future<void> addPoints({
    required String uid,
    required int points,
  }) async {
    await _users.doc(uid).update({
      'points': FieldValue.increment(points),
    });
  }

  // 🔹 تحديث المستوى (اختياري)
  Future<void> updateLevel({
    required String uid,
    required int level,
  }) async {
    await _users.doc(uid).update({
      'level': level,
    });
  }
}
