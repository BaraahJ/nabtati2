import 'package:flutter/material.dart';
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

  String category = 'أزهار';
  String condition = 'جديدة';

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
            _buildTextField("السعر", priceController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: category,
                    dropdownColor: white,
                    items: const [
                      DropdownMenuItem(value: 'أزهار', child: Text('أزهار')),
                      DropdownMenuItem(value: 'صبار', child: Text('صبار')),
                      DropdownMenuItem(value: 'نباتات زينة', child: Text('نباتات زينة')),
                    ],
                    onChanged: (val) => setState(() => category = val!),
                    decoration: _dropdownDecoration("الفئة"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: condition,
                    dropdownColor: white,
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "نشر المنتج",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
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
