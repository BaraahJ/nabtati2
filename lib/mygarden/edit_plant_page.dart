/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../plant.dart';
import '../colors.dart';
import 'package:go_router/go_router.dart';

class EditPlantPage extends StatefulWidget {
  final Plant plant;

  const EditPlantPage({super.key, required this.plant});

  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  late TextEditingController _nameController;
  late TextEditingController _lightController;
  late TextEditingController _temperatureController;
  late bool _isOutdoor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _lightController = TextEditingController(text: widget.plant.light ?? '');
    _temperatureController =
        TextEditingController(text: widget.plant.temperature ?? '');
    _isOutdoor = widget.plant.isOutdoor;
  }

  void _saveChanges() {
    widget.plant.name = _nameController.text;
    widget.plant.light = _lightController.text;
    widget.plant.temperature = _temperatureController.text;
    widget.plant.isOutdoor = _isOutdoor;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("تم حفظ التعديلات 🌿")));

    // نغلق صفحة التعديل (الصفحة التي فتحتها عبر context.push)
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "تعديل النبتة",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 200, 210, 185).withOpacity(0.9),
                  const Color.fromARGB(255, 235, 213, 237).withOpacity(0.7),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // صورة النبتة
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  widget.plant.image,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 25),

              // الاشياء الي ممكن يصير عليها التعديل
              _buildTextField("اسم النبتة", _nameController),
              const SizedBox(height: 15),
              _buildTextField("الإضاءة المناسبة", _lightController),
              const SizedBox(height: 15),
              _buildTextField("درجة الحرارة", _temperatureController),
              const SizedBox(height: 20),

              // نوع النبتة
              Row(
                children: [
                  Text(
                    "نوع النبتة:",
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<bool>(
                        value: _isOutdoor,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text("خارجية (Outdoor)"),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text("داخلية (Indoor)"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isOutdoor = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // زر الحفظ
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF93B194),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  elevation: 3,
                ),
                child: Text(
                  "حفظ التعديلات",
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.tajawal(fontSize: 16, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xFF93B194), width: 1.5),
        ),
      ),
    );
  }
}
*/