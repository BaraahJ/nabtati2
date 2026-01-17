import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String ownerId;
  final String content;
  final String imageUrl;
  final List<String> likes;
  final int commentsCount;
  final Timestamp? createdAt;

  PostModel({
    required this.id,
    required this.ownerId,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.commentsCount,
    this.createdAt,
  });

  bool isLikedBy(String uid) => likes.contains(uid);

  factory PostModel.fromMap(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'],
      ownerId: data['userId'],
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: data['createdAt'],
    );
  }
}
