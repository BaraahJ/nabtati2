import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPostModel {
  final String id;
  final String userId;

  final String title;
  final String description;
  final String price;
  final String city;
  final String category;
  final List<String> images;

  final List<String> likes;
  final int commentsCount;
  final Timestamp? createdAt;

  MarketPostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.category,
    required this.images,
    required this.likes,
    required this.commentsCount,
    this.createdAt,
  });

  bool isLikedBy(String uid) => likes.contains(uid);

  factory MarketPostModel.fromMap(String id, Map<String, dynamic> data) {
    return MarketPostModel(
      id: id,
      userId: data['userId'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? '',
      city: data['city'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: data['createdAt'],
    );
  }
}
