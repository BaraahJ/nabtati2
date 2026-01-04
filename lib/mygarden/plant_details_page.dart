/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import 'edit_plant_page.dart';
import '../plant.dart';

class PlantDetailsPage extends StatefulWidget {
  final Plant plant;

  const PlantDetailsPage({super.key, required this.plant});

  @override
  State<PlantDetailsPage> createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [
    "ضعي النبتة في مكان مشمس، ولا تفرطي في السقي."
  ];

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 235, 225),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.plant.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255)),
                    onPressed: () async {
                      final updatedPlant = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPlantPage(plant: widget.plant),
                        ),
                      );

                      if (updatedPlant != null && updatedPlant is Plant) {
                        setState(() {
                          widget.plant.name = updatedPlant.name;
                          widget.plant.light = updatedPlant.light;
                          widget.plant.temperature = updatedPlant.temperature;
                          widget.plant.isOutdoor = updatedPlant.isOutdoor;
                        });
                        Navigator.pop(context, updatedPlant);
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.plant.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text("", style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              color: const Color.fromARGB(255, 226, 235, 225).withOpacity(0.8),
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

  

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDataRow(widget.plant.light ?? "غير محدد", ":الإضاءة"),
        _buildDataRow(widget.plant.temperature ?? "غير محددة", ":درجة الحرارة"),
        _buildDataRow(widget.plant.isOutdoor ? "خارجية" : "داخلية", ":النوع"),
      ],
    );
  }


  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Text(
                      "لا توجد ملاحظات بعد ",
                      style: GoogleFonts.tajawal(fontSize: 18, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(_notes[index]),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            _notes.removeAt(index);
                          });
                        },
                        child: GestureDetector(
                          onTap: () => _editNoteDialog(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.note_alt, color: Colors.green, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _notes[index],
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 17,
                                      color: textColor,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // إضافة ملاحظة جديدة
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "أضف ملاحظة جديدة...",
                    hintStyle: GoogleFonts.tajawal(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_noteController.text.trim().isNotEmpty) {
                    setState(() {
                      _notes.add(_noteController.text.trim());
                      _noteController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lavender,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  تعديل ملاحظة
  void _editNoteDialog(int index) {
    final controller = TextEditingController(text: _notes[index]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تعديل الملاحظة", style: GoogleFonts.tajawal()),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: "اكتب الملاحظة الجديدة"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: GoogleFonts.tajawal()),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes[index] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: Text("حفظ", style: GoogleFonts.tajawal(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  //  تأكيد حذف النبتة
  void _confirmDeletePlant(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد الحذف", style: GoogleFonts.tajawal()),
        content: Text(
          "هل أنت متأكد أنك تريد حذف هذه النبتة؟ ",
          style: GoogleFonts.tajawal(),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: GoogleFonts.tajawal()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // رجوع للصفحة السابقة بعد الحذف
            },
            child: Text("حذف", style: GoogleFonts.tajawal(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Widget _buildHealthTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_rounded, size: 70, color: textColor.withOpacity(0.6)),
          const SizedBox(height: 10),
          Text(
            "حلّل حالة النبتة من خلال صورة ",
            style: GoogleFonts.tajawal(fontSize: 18, color: textColor),
          ),
        ],
      ),
    );
  }
  Widget _buildCareTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard(Icons.water_drop, "الري", "كل أسبوعين", "القادم بعد ٣ أيام"),
        const SizedBox(height: 15),
        _buildInfoCard(Icons.grass, "التسميد", "كل شهر", "القادم بعد ١٠ أيام"),
        const SizedBox(height: 15),
        _buildInfoCard(Icons.local_florist, "إعادة الزراعة", "كل سنتين", "متأخرة بـ ٥ أيام"),
      ],
    );
  }
    Widget _buildInfoCard(IconData icon, String title, String freq, String next) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: green.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: textColor, size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                const SizedBox(height: 3),
                Text(freq,
                    style: GoogleFonts.tajawal(fontSize: 15, color: Colors.grey[700])),
                Text("التالي: $next",
                    style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.tajawal(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}*/
