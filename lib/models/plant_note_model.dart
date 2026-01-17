import 'package:cloud_firestore/cloud_firestore.dart';

class PlantNote {
  final String id;
  final String text;
  final String imageUrl;
  final DateTime createdAt;

  PlantNote({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
  });

  factory PlantNote.fromFirestore(
      Map<String, dynamic> data, String id) {
    return PlantNote(
      id: id,
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}