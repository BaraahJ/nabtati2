import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/post_service.dart';
import '../../services/cloudinary_service.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _contentController = TextEditingController();
  final PostService _postService = PostService();

  File? _image;
  bool _isLoading = false;

  final GlobalKey _repaintKey = GlobalKey();

  /// اختيار صورة من الاستديو
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
    });
  }

  /// التقاط صورة بالكاميرا
  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
    });
  }

  /// التقاط الصورة النهائية (مثل إنستغرام)
  Future<File?> _captureImage() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final file = File('${_image!.path}_final.png');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// نشر البوست
  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_contentController.text.trim().isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب شيئًا أو أضف صورة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = '';

      if (_image != null) {
        final finalImage = await _captureImage();
        if (finalImage != null) {
          imageUrl = await CloudinaryService.uploadPost(finalImage);
        }
      }

      await _postService.addPost(
        _contentController.text.trim(),
        imageUrl,
        user.uid,
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إنشاء منشور',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// إطار الصورة + زر الكاميرا
              Column(
                children: [
                  RepaintBoundary(
                    key: _repaintKey,
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey[200], // لون فاتح للإطار
                        ),
                        child: _image == null
                            ? GestureDetector(
                                onTap: _pickFromGallery,
                                child: const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ExtendedImage.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  mode: ExtendedImageMode.gesture,
                                  initGestureConfigHandler: (_) {
                                    return GestureConfig(
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      speed: 1.0,
                                      inertialSpeed: 100.0,
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// زر التقاط صورة بالكاميرا
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('التقاط صورة بالكاميرا'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// نص البوست
              TextField(
                controller: _contentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'اكتب وصفًا للمنشور...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// زر النشر
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'نشر',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
