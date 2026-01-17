import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plant_model.dart';
import '../models/garden_plant_model.dart';
import '../models/plant_note_model.dart';

class GardenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ================= ADD PLANT TO GARDEN =================
  Future<void> addPlantToGarden(Plant plant) async {
    final doc = _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .doc();

    await doc.set({
      'plantId': plant.id,
      'name': plant.name,
      'category': plant.category,
      'description': plant.description,
      'benefits': plant.benefits,
      'planting': plant.planting,
      'sunlight': plant.sunlight,
      'water': plant.water,
      'soil': plant.soil,
      'tempreture': plant.temperature,
      'tasmeed': plant.tasmeed,
      'pruning-harvest': plant.pruningHarvest,
      'image': plant.imageUrl,

      'watering': {
        'description': plant.watering.description,
        'frequency_days': plant.watering.frequencyDays,
      },
      'fertilizing': {
        'description': plant.fertilizing.description,
        'frequency_days': plant.fertilizing.frequencyDays,
      },
      'pruning': {
        'description': plant.pruning.description,
        'frequency_days': plant.pruning.frequencyDays,
      },

      'createdAt': FieldValue.serverTimestamp(),
    });

    //// 🔴 ADDED — إنشاء المهام (بدون اسم النبتة)
    await _createTask(
      plantId: doc.id,
      type: "watering",
      frequencyDays: plant.watering.frequencyDays,
    );

    await _createTask(
      plantId: doc.id,
      type: "fertilizing",
      frequencyDays: plant.fertilizing.frequencyDays,
    );

    await _createTask(
      plantId: doc.id,
      type: "pruning",
      frequencyDays: plant.pruning.frequencyDays,
    );
  }

  //// 🔴 ADDED — دالة إنشاء مهمة
  Future<void> _createTask({
    required String plantId,
    required String type,
    required int frequencyDays,
  }) async {
    if (frequencyDays <= 0) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('tasks')
        .add({
      'plantId': plantId,
      'type': type, // watering / fertilizing / pruning
      'dueDate': Timestamp.fromDate(
        DateTime.now().add(Duration(days: frequencyDays)),
      ),
      'doneAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= GET GARDEN PLANTS =================
  Stream<List<GardenPlant>> getGardenPlants() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => GardenPlant.fromFirestore(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // ================= NOTES =================
  Future<void> addNoteToPlant({
    required String plantId,
    required String text,
    required String imageUrl,
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .doc(plantId)
        .collection('notes')
        .add({
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<PlantNote>> getPlantNotes(String plantId) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .doc(plantId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PlantNote.fromFirestore(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> deleteNote({
    required String plantId,
    required String noteId,
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('garden')
        .doc(plantId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}