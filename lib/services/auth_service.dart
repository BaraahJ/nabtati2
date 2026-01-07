import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= REGISTER WITH EMAIL =================
    Future<User?> registerWithEmail({
      required String username,
      required String email,
      required String password,
    }) async {
      try {
        // 1️⃣ التأكد أن اليوزرنيم غير مكرر
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          throw 'اسم المستخدم مستخدم مسبقاً';
        }

        // 2️⃣ إنشاء الحساب (Firebase Auth)
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = cred.user;
        if (user == null) throw 'فشل إنشاء الحساب';

        // 3️⃣ تخزين المستخدم في Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,         
          'name': username,              
          'email': email,
          'provider': 'email',
          'photoUrl': '',
          'bio': '',
          'points': 0,
          'level': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;

      } on FirebaseAuthException catch (e) {
        throw _mapAuthError(e);
      } catch (e) {
        throw e.toString();
      }
    }


  // ================= LOGIN WITH EMAIL =================
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw 'يرجى تعبئة البريد وكلمة المرور';
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      final doc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'الحساب غير موجود، يرجى إنشاء حساب';
      }

      return cred.user;

    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ================= GOOGLE REGISTER =================
  Future<User?> registerWithGoogle() async {
  try {
    final googleSignIn = GoogleSignIn(scopes: ['email']);
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw 'تم إلغاء تسجيل الدخول';
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // تسجيل الدخول / إنشاء الحساب في Firebase Auth
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;

    if (user == null) {
      throw 'فشل إنشاء الحساب';
    }

    final userDoc =
        _firestore.collection('users').doc(user.uid);

    // نتحقق هل الوثيقة موجودة
    final docSnapshot = await userDoc.get();

    // إذا لم يكن له حساب مسبق → ننشئه
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'username': user.displayName?.replaceAll(' ', '_').toLowerCase() ?? 'user123', 
        'name': user.displayName ?? user.displayName?.replaceAll(' ', '_') ?? 'user123',

        'email': user.email ?? '',
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // لو موجود مسبقًا → نمنع التسجيل المكرر
      throw 'هذا الحساب مسجّل مسبقًا، يرجى تسجيل الدخول';
    }

    return user;

  } on FirebaseAuthException catch (e) {
    throw _mapAuthError(e);
  }
}

  // ================= GOOGLE LOGIN =================
  Future<User?> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw 'تم الإلغاء';

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);

      final doc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'هذا الحساب غير مسجّل، يرجى إنشاء حساب';
      }

      return cred.user;

    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ================= LOGOUT =================
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // ================= ERROR MAPPING =================
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'الحساب غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد مستخدم مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
