import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/reply_model.dart';

class CommentService {
  final _firestore = FirebaseFirestore.instance;

 Stream<List<CommentModel>> getComments(String postId) {
  return _firestore
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt', descending: true) // ← هذا مهم جدًا
      .snapshots()
      .map((snap) {
    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // تعيين الـ id
      return CommentModel.fromMap(data);
    }).toList();
  });
}


Future<void> addComment({
  required String postId,
  required String userId,
  required String text,
}) async {
  final postRef = _firestore.collection('posts').doc(postId);

  // إنشاء مستند جديد مع id تلقائي
  final newDoc = postRef.collection('comments').doc(); 

  await newDoc.set({
    'userId': userId,
    'text': text,
    'likes': [],
    'repliesCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await postRef.update({
    'commentsCount': FieldValue.increment(1),
  });
}


  Stream<List<ReplyModel>> getReplies(
    String postId,
    String commentId,
  ) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReplyModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> addReply({
    required String postId,
    required String commentId,
    required String userId,
    required String text,
  }) async {
    final ref = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await ref.collection('replies').add({
      'userId': userId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
    });

    await ref.update({
      'repliesCount': FieldValue.increment(1),
    });
  }
  // لايك / أنلايك
Future<void> toggleLikeComment({
  required String postId,
  required String commentId,
  required String uid,
  required bool isLiked,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  await ref.update({
    'likes': isLiked
        ? FieldValue.arrayRemove([uid])
        : FieldValue.arrayUnion([uid]),
  });
}

Future<void> toggleReplyLike({
  required String postId,
  required String commentId,
  required String replyId,
  required String uid,
  required bool isLiked,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .doc(replyId);

  await ref.update({
    'likes': isLiked
        ? FieldValue.arrayRemove([uid])
        : FieldValue.arrayUnion([uid]),
  });
}
Future<void> deleteReply({
  required String postId,
  required String commentId,
  required String replyId,
}) async {
  final commentRef = _firestore
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  await commentRef
      .collection('replies')
      .doc(replyId)
      .delete();

  await commentRef.update({
    'repliesCount': FieldValue.increment(-1),
  });
}



// حذف تعليق
Future<void> deleteComment({
  required String postId,
  required String commentId,
}) async {
  final postRef =
      FirebaseFirestore.instance.collection('posts').doc(postId);

  await postRef
      .collection('comments')
      .doc(commentId)
      .delete();

  await postRef.update({
    'commentsCount': FieldValue.increment(-1),
  });
}


}
