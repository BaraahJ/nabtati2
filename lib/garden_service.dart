import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'plant_model.dart';
import 'garden_plant_model.dart';

class GardenService {
  final _firestore = FirebaseFirestore.instance;

  String get _uid =>
      FirebaseAuth.instance.currentUser!.uid;

  /// ADD plant to garden
  Future<void> addPlantToGarden(Plant plant) async {
    final doc = _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .doc();

    await doc.set({
      'plantId': plant.id,
      'name': plant.name,
      'imageUrl': plant.imageUrl,
      'wateringDays': plant.watering.frequencyDays,
      'fertilizingDays': plant.fertilizing.frequencyDays,
      'remindersEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// GET garden plants
  Stream<List<GardenPlant>> getGardenPlants() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                GardenPlant.fromFirestore(d.data(), d.id))
            .toList());
  }
}
