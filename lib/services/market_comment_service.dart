import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/reply_model.dart';

class MarketCommentService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('market_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CommentModel.fromMap(data);
      }).toList();
    });
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String text,
  }) async {
    final postRef =
        _firestore.collection('market_posts').doc(postId);

    await postRef.collection('comments').add({
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
        .collection('market_posts')
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
        .collection('market_posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await ref.collection('replies').add({
      'userId': userId,
      'text': text,
      'likes': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await ref.update({
      'repliesCount': FieldValue.increment(1),
    });
  }

  Future<void> toggleLikeComment({
    required String postId,
    required String commentId,
    required String uid,
    required bool isLiked,
  }) async {
    await _firestore
        .collection('market_posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
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
  await _firestore
      .collection('market_posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId)
      .collection('replies')
      .doc(replyId)
      .update({
    'likes': isLiked
        ? FieldValue.arrayRemove([uid])
        : FieldValue.arrayUnion([uid]),
  });
}


  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final postRef =
        _firestore.collection('market_posts').doc(postId);

    await postRef.collection('comments').doc(commentId).delete();

    await postRef.update({
      'commentsCount': FieldValue.increment(-1),
    });
  }

  Future<void> deleteReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    final ref = _firestore
        .collection('market_posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await ref.collection('replies').doc(replyId).delete();

    await ref.update({
      'repliesCount': FieldValue.increment(-1),
    });
  }
}
