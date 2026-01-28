import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/market_service.dart';
import '../../services/cloudinary_service.dart';
import 'package:flutter/services.dart';


class AddMarketPostPage extends StatefulWidget {
  const AddMarketPostPage({super.key});

  @override
  State<AddMarketPostPage> createState() => _AddMarketPostPageState();
}

class _AddMarketPostPageState extends State<AddMarketPostPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();

  String city = 'رام الله';
  String category = 'ازهار';

  List<File> images = [];
  bool loading = false;

  final ImagePicker _picker = ImagePicker();

  final cities = [
    'القدس',
    'رام الله',
    'نابلس',
    'الخليل',
    'غزة',
    'جنين',
    'طولكرم',
    'قلقيلية',
    ''
  ];

  final categories = [
    'ازهار',
    'خضار',
    'اشجار',
    'اعشاب',
    'نباتات داخلية',
  ];

  /// 📸 اختيار صور من المعرض (متعدد)
  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  /// 📷 تصوير بالكاميرا
  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        images.add(File(picked.path));
      });
    }
  }

  /// 🚀 نشر البوست
  Future<void> _submit() async {
    if (_title.text.isEmpty ||
        _desc.text.isEmpty ||
        _price.text.isEmpty ||
        images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول وإضافة صور')),
      );
      return;
    }

    setState(() => loading = true);

    final urls = <String>[];
    for (final img in images) {
      final url = await CloudinaryService.uploadPost(img);
      urls.add(url);
    }

    await MarketService().addMarketPost(
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      price: _price.text.trim(),
      city: city,
      category: category,
      images: urls,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة منتج')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 📝 الاسم
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'اسم المنتج'),
          ),

          /// 📝 الوصف
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),

          /// 💰 السعر
/// 💰 السعر
TextField(
  controller: _price,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  decoration: const InputDecoration(
    labelText: 'السعر',
    prefixIcon: Icon(Icons.attach_money),
  ),
),


          const SizedBox(height: 12),

          /// 📍 المدينة
         DropdownButtonFormField<String>(
  value: city,
  isExpanded: true, // ← مهم جداً
  menuMaxHeight: 300, // ← يعطي مساحة كافية
  items: cities
      .where((c) => c.trim().isNotEmpty)
      .map((c) => DropdownMenuItem(
            value: c,
            child: Text(c),
          ))
      .toList(),
  onChanged: (v) => setState(() => city = v!),
  decoration: const InputDecoration(labelText: 'المدينة'),
),


          const SizedBox(height: 12),

          /// 🏷️ التصنيف
          DropdownButtonFormField<String>(
            value: category,
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => category = v!),
            decoration: const InputDecoration(labelText: 'التصنيف'),
          ),

          const SizedBox(height: 16),

          /// 🖼️ الصور
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text('من المعرض'),
                  onPressed: _pickFromGallery,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('كاميرا'),
                  onPressed: _pickFromCamera,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🧩 عرض الصور المختارة
          if (images.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (_, i) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(images[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => images.removeAt(i));
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          /// 🚀 زر النشر
          ElevatedButton(
            onPressed: loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('نشر المنتج'),
          ),
        ],
      ),
    );
  }
}
