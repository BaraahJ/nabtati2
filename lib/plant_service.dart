import 'package:cloud_firestore/cloud_firestore.dart';
import '../plant_model.dart';

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
}
