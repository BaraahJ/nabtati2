import 'package:cloud_firestore/cloud_firestore.dart';

class GardenPlant {
  final String id;
  final String plantId; // original plant
  final String name;
  final String imageUrl;

  final int wateringDays;
  final int fertilizingDays;
  final bool remindersEnabled;

  final DateTime createdAt;

  GardenPlant({
    required this.id,
    required this.plantId,
    required this.name,
    required this.imageUrl,
    required this.wateringDays,
    required this.fertilizingDays,
    required this.remindersEnabled,
    required this.createdAt,
  });

  factory GardenPlant.fromFirestore(
      Map<String, dynamic> data, String id) {
    return GardenPlant(
      id: id,
      plantId: data['plantId'],
      name: data['name'],
      imageUrl: data['imageUrl'],
      wateringDays: data['wateringDays'] ?? 0,
      fertilizingDays: data['fertilizingDays'] ?? 0,
      remindersEnabled: data['remindersEnabled'] ?? true,
      createdAt:
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'name': name,
      'imageUrl': imageUrl,
      'wateringDays': wateringDays,
      'fertilizingDays': fertilizingDays,
      'remindersEnabled': remindersEnabled,
      'createdAt': createdAt,
    };
  }
}
