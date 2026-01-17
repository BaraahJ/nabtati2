import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors.dart';
import '../models/garden_plant_model.dart';

final cloudinary = CloudinaryPublic('dpmsft8or', 'plantprofilepics', cache: false);

class EditPlantPage extends StatefulWidget {
  final GardenPlant plant;

  const EditPlantPage({super.key, required this.plant});

  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  late TextEditingController _nameController;

  File? _newImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<String?> _uploadImage() async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _newImage!.path,
          folder: 'plant_images',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  // ================= SAVE =================
  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    String imageUrl = widget.plant.imageUrl;

    try {
      if (_newImage != null) {
        final uploadedUrl = await _uploadImage();
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('garden')
          .doc(widget.plant.id)
          .update({
        'name': _nameController.text.trim(),
        'image': imageUrl,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل حفظ التعديلات")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل النبتة"),
        backgroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _newImage != null
                    ? FileImage(_newImage!)
                    : NetworkImage(widget.plant.imageUrl)
                        as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: green,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // NAME FIELD
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "اسم النبتة",
                filled: true,
                fillColor: white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            // SAVE BUTTON
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Color.fromARGB(255, 244, 243, 243))
                  : Text(
                      "حفظ التغييرات",
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}