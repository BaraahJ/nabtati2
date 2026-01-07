import 'package:flutter/material.dart';
import 'plant_search_card.dart';
import '../services/plant_service.dart';
import '../models/plant_model.dart';
import '../plant/plantDesign.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = "";
  String selectedCategory = "الكل";

  final List<String> plantCategories = [
    "الكل",
    "ازهار",
    "خضار",
    "اشجار",
    "اعشاب",
    "نباتات داخلية",
   
  ];

  final PlantService _plantService = PlantService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
              IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF4B8A75),
              ),
              onPressed: () {
                Navigator.pop(context); // يرجع للهوم
              },
              ),

                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: "البحث",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),
                ),
                                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF4B8A75)),
                  iconSize: 34,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          // Categories filter
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: plantCategories.length,
              itemBuilder: (context, index) {
                String category = plantCategories[index];
                bool isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF4B8A75) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),
          // Plants Grid
          Expanded(
            child: StreamBuilder<List<Plant>>(
              stream: _plantService.getPlants(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
  return Center(
    child: Text(
      snapshot.error.toString(),
      textAlign: TextAlign.center,
    ),
  );
}

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("لا يوجد نباتات"));
                }

                final plants = snapshot.data!;

                final filteredPlants = plants.where((plant) {
                  final query = searchText.toLowerCase();
                  final matchesText =
                      plant.name.toLowerCase().contains(query) ||
                      plant.category.toLowerCase().contains(query) ||
                      query.isEmpty;

                  final matchesCategory =
                      selectedCategory == "الكل" || plant.category == selectedCategory;

                  return matchesText && matchesCategory;
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredPlants.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return PlantCard(
                      plant: filteredPlants[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantDesign(plant: filteredPlants[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
