import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant_model.dart';

class PlantService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Plant>> getPlants() {
    return _db.collection('plants').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Plant.fromFirestore(doc.data(), doc.id))
            .toList();
      },
    );
  }


  Future<Plant?> getPlantById(String id) async {
    final doc = await _db.collection('plants').doc(id).get();
    if (!doc.exists) return null;
    return Plant.fromFirestore(doc.data()!, doc.id);
    }
}
