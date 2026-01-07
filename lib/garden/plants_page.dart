import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors.dart';
import '../services/garden_service.dart';
import '../models/garden_plant_model.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "نباتاتي 🌱",
            style: GoogleFonts.tajawal(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<GardenPlant>>(
              stream: GardenService().getGardenPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "لم تقم بإضافة أي نبتة بعد 🌱",
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                final plants = snapshot.data!;

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 5),
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
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            plant.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          plant.name,
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          "💧 كل ${plant.wateringDays} أيام",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
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
