/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//import 'edit_plant_page.dart';
import 'plant_details_page.dart';
import '../colors.dart';
import '../plant.dart';
import 'data/plant_data.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  String searchQuery = "";
  List<Plant> plants = PlantData.plants;

  void _openPlantDetails(int index) async {
    final updatedPlant = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantDetailsPage(plant: plants[index]),
      ),
    );

    if (updatedPlant != null && updatedPlant is Plant) {
      setState(() {
        plants[index] = updatedPlant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlants = plants
        .where((plant) =>
            plant.name.contains(searchQuery) ||
            plant.name.startsWith(searchQuery))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              "حديقتي الصغيرة ",
              style: GoogleFonts.tajawal(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => searchQuery = value.trim()),
                    decoration: InputDecoration(
                      hintText: "ابحث عن نبتتك...",
                      hintStyle: GoogleFonts.tajawal(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
    
  
              ],
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = filteredPlants[index];
                return GestureDetector(
                  onTap: () => _openPlantDetails(index),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              plant.image,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            plant.name,
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
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
        ],
      ),
    );
  }
}*/
