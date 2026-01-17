import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_post_model.dart';

class MarketService {
  final _ref = FirebaseFirestore.instance.collection('market_posts');

  Stream<List<MarketPostModel>> getPosts() {
    return _ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => MarketPostModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addMarketPost({
    required String userId,
    required String title,
    required String description,
    required String price,
    required String city,
    required String category,
    required List<String> images,
  }) async {
    await _ref.add({
      'userId': userId,
      'title': title,
      'description': description,
      'price': price,
      'city': city,
      'category': category,
      'images': images,
      'likes': [],
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String postId) async {
    await _ref.doc(postId).delete();
  }

  Future<void> toggleLike({
    required String postId,
    required String uid,
    required bool isLiked,
  }) async {
    await _ref.doc(postId).update({
      'likes': isLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }


// لايك / أنلايك تعليق
Future<void> toggleLikeComment({
  required String postId,
  required String commentId,
  required String uid,
  required bool isLiked,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('market_posts')
      .doc(postId)
      .collection('comments')
      .doc(commentId);

  await ref.update({
    'likes': isLiked
        ? FieldValue.arrayRemove([uid])
        : FieldValue.arrayUnion([uid]),
  });
}

// لايك / أنلايك رد
Future<void> toggleReplyLike({
  required String postId,
  required String commentId,
  required String replyId,
  required String uid,
  required bool isLiked,
}) async {
  final ref = FirebaseFirestore.instance
      .collection('market_posts')
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

  
}
