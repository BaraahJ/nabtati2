import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors.dart';
import '../services/garden_service.dart';
import '../models/garden_plant_model.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<List<GardenPlant>>(
        stream: GardenService().getGardenPlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "لا توجد مهام حالياً 🎉",
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final plants = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: green.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    "سقي ${plant.name} 💧",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    "كل ${plant.wateringDays} أيام",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.circle_outlined,
                    color: green,
                    size: 26,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
