import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyModel {
  final String id;
  final String userId;
  final String text;
  final List<String> likes;

  ReplyModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.likes,
  });

  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    return ReplyModel(
      id: map['id'],
      userId: map['userId'],
      text: map['text'],
      likes: List<String>.from(map['likes'] ?? []), // ⭐ مهم
    );
  }

  bool isLikedBy(String uid) => likes.contains(uid);
}
