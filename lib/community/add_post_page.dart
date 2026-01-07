/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../colors.dart';

class AddPostPage extends StatefulWidget {
  final Function() onPostAdded; // لإعلام الصفحة الأم بأن منشور جديد أضيف

  const AddPostPage({super.key, required this.onPostAdded});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أضف نصًا أو صورة أولاً")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول للنشر")),
      );
      setState(() => _isLoading = false);
      return;
    }

    String imageUrl = '';
    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_selectedImage!);
      imageUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'username': user.displayName ?? 'مستخدم',
      'userId': user.uid,
      'userImage': user.photoURL,
      'content': _contentController.text.trim(),
      'imageUrl': imageUrl,
      'likes': 0,
      'comments': [],
      'timestamp': FieldValue.serverTimestamp(),
    });

    widget.onPostAdded(); // تحديث الـCommunityPage

    setState(() {
      _isLoading = false;
      _contentController.clear();
      _selectedImage = null;
    });

    Navigator.pop(context); // العودة للصفحة السابقة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'إضافة منشور جديد',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: textColor),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 200, 210, 185).withOpacity(0.9),
                const Color.fromARGB(255, 235, 213, 237).withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب شيئًا عن نباتاتك...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: lavender),
              label: const Text(
                "إضافة صورة",
                style: TextStyle(color: lavender, fontSize: 16),
              ),
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator(color: lavender)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 12),
              ),
              onPressed: _submitPost,
              child: const Text(
                'نشر',
                style: TextStyle(color: white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/