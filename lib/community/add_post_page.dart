import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../colors.dart';

class AddPostPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddPost; //عشان اضافة المنشور 

  const AddPostPage({super.key, required this.onAddPost});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _submitPost() {
    if (_contentController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أضف محتوى أو صورة أولاً")),
      );
      return;
    }

    // إنشاء منشور جديد
    final newPost = {
      'username': 'أنتِ 🌸',
      'userImage': 'https://cdn-icons-png.flaticon.com/512/4333/4333609.png',
      'content': _contentController.text.trim(),
      'imageUrl': _selectedImage?.path ?? '',
      'likes': 0,
      'comments': 0,
    };

    widget.onAddPost(newPost); 
    Navigator.pop(context);
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
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
}
