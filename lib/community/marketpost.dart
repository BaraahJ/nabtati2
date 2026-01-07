import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../colors.dart';

class AddMarketPostPage extends StatefulWidget {
  const AddMarketPostPage({super.key});

  @override
  State<AddMarketPostPage> createState() => _AddMarketPostPageState();
}

class _AddMarketPostPageState extends State<AddMarketPostPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  String? selectedCategory;
  String condition = 'جديدة';
  bool _isLoading = false;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('market_categories').get();
    setState(() {
      categories = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      if (categories.isNotEmpty) selectedCategory = categories[0];
    });
  }

  Future<void> _submitProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول لإضافة منتج")),
      );
      return;
    }
    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("املأ جميع الحقول")),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('market_posts').add({
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'price': priceController.text.trim(),
      'imageUrl': imageController.text.trim(),
      'category': selectedCategory,
      'condition': condition,
      'ownerId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة منتج جديد"),
        backgroundColor: purble,
        elevation: 0,
      ),
      backgroundColor: lightpink,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "أضف منتجك للسوق",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("اسم المنتج", nameController),
            const SizedBox(height: 12),
            _buildTextField("الوصف", descriptionController, maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField("رابط الصورة (اختياري)", imageController),
            const SizedBox(height: 12),
            _buildTextField("السعر", priceController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                    decoration: _dropdownDecoration("الفئة"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: condition,
                    items: const [
                      DropdownMenuItem(value: 'جديدة', child: Text('جديدة')),
                      DropdownMenuItem(value: 'مستعملة', child: Text('مستعملة')),
                    ],
                    onChanged: (val) => setState(() => condition = val!),
                    decoration: _dropdownDecoration("الحالة"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator(color: lavender)
                : ElevatedButton(
              onPressed: _submitProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "نشر المنتج",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textColor),
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textColor),
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}