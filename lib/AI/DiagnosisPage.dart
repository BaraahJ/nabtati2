import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  File? _image;
  String _diseaseName = "";
  String _treatment = "";
  bool _loading = false;

  final picker = ImagePicker();
  final String _serverUrl =
      'https://plant-disease-api-nv3f.onrender.com/predict/';

  Future<void> _sendImage(File imageFile) async {
    setState(() => _loading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      var resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      setState(() {
        _diseaseName = data['disease'] ?? 'غير معروف';
        _treatment = data['treatment'] ?? 'لا يوجد علاج';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _diseaseName = 'خطأ أثناء الاتصال بالسيرفر';
        _treatment = '';
        _loading = false;
      });
    }
  }

  Future<void> captureImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      _image = File(picked.path);
      await _sendImage(_image!);
    }
  }

  Future<void> pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _image = File(picked.path);
      await _sendImage(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("تشخيص النبات"),
        backgroundColor: Colors.green[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("التقاط صورة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[200],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("اختر من المعرض"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[200],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 220, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(color: Colors.green),
            if (!_loading && _diseaseName.isNotEmpty) ...[
              Card(
                color: Colors.green[100],
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "التشخيص",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _diseaseName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "العلاج",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _treatment,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}