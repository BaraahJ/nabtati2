import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  
  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc.data()!);
  }

  Stream<AppUser?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc.data()!);
    });
  }

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


 
  Future<void> updatePhoto({
    required String uid,
    required String photoUrl,
  }) async {
    await _users.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }


  Future<void> updateLevel({
    required String uid,
    required int level,
  }) async {
    await _users.doc(uid).update({
      'level': level,
    });
  }





Future<void> addPoints({
    required String uid,
    required int points,
  }) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return;
    int currentPoints = doc.data()?['points'] ?? 0;
    if (currentPoints >= 100) return;
    int newPoints = currentPoints + points;
    if (newPoints > 100) newPoints = 100;
    await _users.doc(uid).update({'points': newPoints});
  }

  Future<void> removePoints(String uid, int points) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return;
    int currentPoints = doc.data()?['points'] ?? 0;
    if (currentPoints >= 100) return;
    int newPoints = currentPoints - points;
    if (newPoints < 0) newPoints = 0;
    await _users.doc(uid).update({'points': newPoints});
  }
  

  Future<void> decrementIdentifyAttempts(String uid) async {
    await _users.doc(uid).update({
      'identifyAttempts': FieldValue.increment(-1),
    });
  }

  Future<void> decrementDiagnoseAttempts(String uid) async {
    await _users.doc(uid).update({
      'diagnoseAttempts': FieldValue.increment(-1),
    });
  }





}

