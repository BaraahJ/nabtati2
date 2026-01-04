import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'plant_model.dart';

class PlantDesign extends StatefulWidget {
  final Plant plant;

  const PlantDesign({
    super.key,
    required this.plant,
  });

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
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ================= CATEGORY =================
            Text(
              plant.category,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // ================= DESCRIPTION =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                plant.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= ADD BUTTON =================
            ElevatedButton.icon(
              onPressed: () {},
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

            // ================= INFO CARDS (COMMENTED) =================
            /*
            Row(
              children: [
                infoCard(...),
                infoCard(...),
                infoCard(...),
              ],
            ),
            */

            // ================= EXPANDABLE SECTIONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  expandableCard(
                    title: "فوائد النبتة",
                    content: plant.benefits,
                    icon: Icons.favorite_border,
                  ),

                  expandableCard(
                    title: "الزراعة",
                    content: plant.planting,
                    icon: Icons.grass,
                  ),

                  expandableCard(
                    title: "التقليم والحصاد",
                    content: plant.pruningHarvest,
                    icon: Icons.content_cut,
                  ),

                  expandableCard(
                    title: "التربة",
                    content: plant.soil,
                    icon: Icons.terrain,
                  ),

                  expandableCard(
                    title: "الضوء",
                    content: plant.sunlight,
                    icon: Icons.wb_sunny_rounded,
                  ),

                  expandableCard(
                    title: "التسميد",
                    content: plant.tasmeed,
                    icon: Icons.local_florist,
                  ),

                  expandableCard(
                    title: "الحرارة",
                    content: plant.temperature,
                    icon: Icons.thermostat_rounded,
                  ),

                  expandableCard(
                    title: "المياه",
                    content: plant.water,
                    icon: Icons.water_drop_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EXPANDABLE CARD =================
  Widget expandableCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(icon, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.8),
          ),
        ],
      ),
    );
  }
}
