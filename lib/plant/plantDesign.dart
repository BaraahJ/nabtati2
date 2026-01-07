import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/plant_model.dart';
import '../services/garden_service.dart';

class PlantDesign extends StatefulWidget {
  final Plant plant;

  const PlantDesign({super.key, required this.plant});

  @override
  State<PlantDesign> createState() => _PlantDesignState();
}

class _PlantDesignState extends State<PlantDesign> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 253, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 5,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= IMAGE =================
            CarouselSlider(
              items: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                  child: Image.network(
                    plant.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ],
              options: CarouselOptions(
                height: screenHeight * .35,
                viewportFraction: 1,
              ),
            ),

            const SizedBox(height: 18),

            // ================= NAME =================
            Text(
              plant.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ================= CATEGORY =================
            Text(
              plant.category,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // ================= DESCRIPTION =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExpandableText(
                text: plant.description,
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 25),

            // ================= ADD BUTTON =================
            ElevatedButton.icon(
             onPressed: () async {
              try {
                await GardenService().addPlantToGarden(plant);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🌱 تمت إضافة النبتة إلى حديقتك"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ خطأ: ${e.toString()}"),
                  ),
                );
              }
            },
              icon: const Icon(Icons.add_circle_outline,
                  color: Color.fromARGB(255, 36, 200, 21)),
              label: const Text(
                'أضف إلى حديقتي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= INFO CARDS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  InfoCard(
                    title: "فوائد النبتة",
                    content: plant.benefits,
                    icon: Icons.favorite,
                    iconColor: Colors.redAccent,
                  ),

                  InfoCard(
                    title: "الزراعة",
                    content: plant.planting,
                    icon: Icons.grass,
                    iconColor: Colors.green,
                  ),

                  InfoCard(
                    title: "التقليم والحصاد",
                    content: plant.pruningHarvest,
                    icon: Icons.content_cut,
                    iconColor: Colors.brown,
                  ),

                  InfoCard(
                    title: "التربة",
                    content: plant.soil,
                    icon: Icons.terrain,
                    iconColor: Colors.orange,
                  ),

                  InfoCard(
                    title: "الضوء",
                    content: plant.sunlight,
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.yellow.shade700,
                  ),

                  InfoCard(
                    title: "التسميد",
                    content: plant.tasmeed,
                    icon: Icons.local_florist,
                    iconColor: Colors.green.shade700,
                  ),

                  InfoCard(
                    title: "الحرارة",
                    content: plant.temperature,
                    icon: Icons.thermostat_rounded,
                    iconColor: Colors.red.shade400,
                  ),

                  InfoCard(
                    title: "المياه",
                    content: plant.water,
                    icon: Icons.water_drop_rounded,
                    iconColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= INFO CARD =========================
class InfoCard extends StatefulWidget {
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
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool isExpanded = false;

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
        initiallyExpanded: false,
        leading: Icon(widget.icon, color: widget.iconColor, size: 26),
        title: Text(
          widget.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 17),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          ExpandableText(
            text: widget.content,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

// ========================= EXPANDABLE TEXT =========================
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({super.key, required this.text, this.maxLines = 3});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(
      text: widget.text,
      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
    );

    return LayoutBuilder(builder: (context, size) {
      final painter = TextPainter(
        maxLines: widget.maxLines,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
        text: span,
      )..layout(maxWidth: size.maxWidth);

      final exceeded = painter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: isExpanded ? null : widget.maxLines,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
          ),
          if (exceeded)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? "اقرأ أقل" : "اقرأ المزيد",
                style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      );
    });
  }
}
