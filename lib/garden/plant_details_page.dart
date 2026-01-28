import 'dart:io'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nabtati/AI/DiagnosisPage.dart';
import '../AI/PlantIdentifierPage.dart';
import '../services/garden_service.dart';
import '../models/plant_note_model.dart';
import 'edit_plant_page.dart';

import '../../colors.dart';
import '../models/garden_plant_model.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

final cloudinary = CloudinaryPublic('dpmsft8or', 'notes_pics', cache: false);

class PlantDetailsPage extends StatefulWidget {
  final GardenPlant plant;
  
  const PlantDetailsPage({super.key, required this.plant});
  

  @override
  State<PlantDetailsPage> createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GardenPlant _plant;

  final TextEditingController _noteController = TextEditingController();
  final GardenService _gardenService = GardenService();

  File? _image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _plant = widget.plant;
  }


    Future<void> _reloadPlant() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('garden')
        .doc(_plant.id)
        .get();

    if (!doc.exists) return;

    setState(() {
      _plant = GardenPlant.fromFirestore(doc.data()!, doc.id);
    });
  }

    Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // يمكنك أيضًا استخدام ImageSource.camera لتحديد الكاميرا

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // حفظ الصورة في المتغير
      });
    }
  }
  

  // رفع الصورة إلى Cloudinary
  Future<String> _uploadImageToCloudinary() async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_image!.path, folder: 'plant_notes'), // رفع الصورة إلى المجلد "plant_notes"
      );
      return response.secureUrl; // الرابط الآمن للصورة
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // في حال حدوث خطأ نرجع رابط فارغ
    }
  }

  // إضافة ملاحظة مع الصورة إلى Firestore
  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    String imageUrl = '';

    try {
      if (_image != null) {
        imageUrl = await _uploadImageToCloudinary();

        if (imageUrl.isEmpty) {
          throw Exception("Image upload failed");
        }
      }

      await _gardenService.addNoteToPlant(
        plantId: widget.plant.id,
        text: _noteController.text.trim(),
        imageUrl: imageUrl,
      );

      _noteController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل رفع الصورة")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  Future<void> _deleteNote(String noteId) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('garden')
        .doc(widget.plant.id)
        .collection('notes')
        .doc(noteId)
        .delete();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("فشل حذف الملاحظة")),
    );
  }
}
  void _confirmDeleteNote(BuildContext context, PlantNote note) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("حذف الملاحظة"),
      content: const Text("هل أنت متأكد أنك تريد حذف هذه الملاحظة؟"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await _deleteNote(note.id);
          },
          child: const Text(
            "حذف",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}



  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} • "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF7),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Stack(
              children: [
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_plant.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // BACK
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // ✏️ EDIT (FIXED)
                Positioned(
                  top: 10,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.edit,
                          color: Color.fromARGB(255, 238, 235, 243)),
                      onPressed: () async{
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditPlantPage(plant: _plant),
                          ),
                        );
                        await _reloadPlant();
                      },
                    ),
                  ),
                ),

                // NAME
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Text(
                    _plant.name,
                    style: GoogleFonts.tajawal(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),


            /// TABS
            Container(
              color: Colors.transparent,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: textColor,
                unselectedLabelColor: Colors.grey[700],
                labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "حول"),
                  Tab(text: "ملاحظات"),
                  Tab(text: "الصحة"),
                  Tab(text: "العناية"),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(),
                  _buildNotesTab(),
                  _buildHealthTab(),
                  _buildCareTab(),
                ],
              ),
            ),

            /// DELETE BUTTON
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lavender,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _confirmDeletePlant(context),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  "حذف النبتة",
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ABOUT TAB =================
  
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfoCard(
          title: "فوائد النبتة",
          content: _plant.benefits,
          icon: Icons.favorite,
          iconColor: Colors.redAccent,
        ),
        InfoCard(
          title: "الزراعة",
          content: _plant.planting,
          icon: Icons.grass,
          iconColor: Colors.green,
        ),
        InfoCard(
          title: "التسميد",
          content: _plant.tasmeed,
          icon: Icons.local_florist,
          iconColor: Colors.green.shade700,
        ),
        InfoCard(
          title: "التقليم والحصاد",
          content: _plant.pruningHarvest,
          icon: Icons.content_cut,
          iconColor: Colors.brown,
        ),
        InfoCard(
          title: "التربة",
          content: _plant.soil,
          icon: Icons.terrain,
          iconColor: Colors.orange,
        ),
        InfoCard(
          title: "الضوء",
          content: _plant.sunlight,
          icon: Icons.wb_sunny_rounded,
          iconColor: Colors.yellow.shade700,
        ),
        InfoCard(
          title: "الحرارة",
          content: _plant.temperature,
          icon: Icons.thermostat_rounded,
          iconColor: Colors.red.shade400,
        ),
        InfoCard(
          title: "المياه",
          content: _plant.water,
          icon: Icons.water_drop_rounded,
          iconColor: Colors.blue,
        ),
      ],
    );
  }


  // ================= NOTES TAB (LOCAL) =================
  Widget _buildNotesTab() { 
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<PlantNote>>(
                stream:
                    _gardenService.getPlantNotes(widget.plant.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!;

                  if (notes.isEmpty) {
                    return Center(
                      child: Text(
                        "لا توجد ملاحظات بعد",
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];

                       return GestureDetector(
                      onLongPress: () =>
                          _confirmDeleteNote(context, note),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(note.createdAt),
                              style: GoogleFonts.tajawal(
                                  fontSize: 11,
                                  color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              note.text,
                              style: GoogleFonts.tajawal(
                                fontSize: 15.5,
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (note.imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(16),
                                child: Image.network(
                                  note.imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),


            /// ✅ PREVIEW IMAGE
            if (_image != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _image!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () {
                          setState(() => _image = null);
                        },
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            /// ADD NOTE BAR
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _image == null
                        ? Icons.add_photo_alternate_outlined
                        : Icons.image,
                    color: lavender,
                    size: 26,
                  ),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "أضف ملاحظة...",
                      filled: true,
                      fillColor: white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isUploading ? null : _addNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lavender,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send,
                          color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );
    }


  // ================= HEALTH TAB =================
  Widget _buildHealthTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(60),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagnosisPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor.withOpacity(0.1), // خلفية خفيفة
              ),
              child: Icon(
                Icons.camera_alt,
                size: 70,
                color: textColor, // أوضح من قبل
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "حلّل حالة النبتة من خلال صورة",
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  // ================= CARE TAB =================
Widget _buildCareTab() {
  return ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _buildInfoCard(
        Icons.water_drop,
        "الري",
        _plant.watering.description,
        "كل ${_plant.watering.frequencyDays} يوم",
      ),

      
      if (widget.plant.fertilizing.description.isNotEmpty)
        ...[
          const SizedBox(height: 15),
          _buildInfoCard(
            Icons.grass,
            "التسميد",
            _plant.fertilizing.description,
            "كل ${_plant.fertilizing.frequencyDays} يوم",
          ),
        ],

      
      if (widget.plant.pruning.description.isNotEmpty)
        ...[
          const SizedBox(height: 15),
          _buildInfoCard(
            Icons.local_florist,
            "التقليم",
            _plant.pruning.description,
            "كل ${_plant.pruning.frequencyDays} يوم",
          ),
        ],
    ],
  );
}

  // ================= DELETE =================
 void _confirmDeletePlant(BuildContext pageContext) {
  showDialog(
    context: pageContext,
    builder: (dialogContext) => AlertDialog(
      title: const Text("تأكيد الحذف"),
      content: const Text("هل أنت متأكد من حذف هذه النبتة؟"),
      actions: [
        TextButton(
          onPressed: () {
            // ✅ بس سكّر الديالوق
            Navigator.of(dialogContext).pop();
          },
          child: const Text("إلغاء"),
        ),
        TextButton(
          onPressed: () async {
            // ✅ سكّر الديالوق أولاً
            Navigator.of(dialogContext).pop();

            // ✅ احذف
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('garden')
                .doc(widget.plant.id)
                .delete();

            // ✅ بعد الحذف سكّر صفحة التفاصيل
            if (!mounted) return;
            Navigator.of(pageContext).pop();
          },
          child: const Text("حذف", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  // ================= UI HELPERS =================
  Widget _buildInfoCard(
      IconData icon, String title, String desc, String freq) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: green),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.tajawal(
                        fontSize: 15, color: Colors.grey[700])),
                Text(freq,
                    style: GoogleFonts.tajawal(
                        fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String value, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
//////////////////////////////////////////////////////////////
/// EXPANDABLE TEXT
//////////////////////////////////////////////////////////////

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: isExpanded ? null : widget.maxLines,
          overflow:
              isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              isExpanded ? "اقرأ أقل" : "اقرأ المزيد",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
//////////////////////////////////////////////////////////////
/// INFO CARD
//////////////////////////////////////////////////////////////

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          ExpandableText(
            text: content,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}