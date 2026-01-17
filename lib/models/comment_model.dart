import 'package:cloud_firestore/cloud_firestore.dart';
class CommentModel {
  final String id;
  final String userId;
  final String text;
  final List<String> likes;
  final int repliesCount;
  final Timestamp? createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.likes,
    required this.repliesCount,
    this.createdAt,
  });

  bool isLikedBy(String uid) => likes.contains(uid);

  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      id: data['id'],
      userId: data['userId'],
      text: data['text'],
      likes: List<String>.from(data['likes'] ?? []),
      repliesCount: data['repliesCount'] ?? 0,
      createdAt: data['createdAt'],
    );
  }
}
