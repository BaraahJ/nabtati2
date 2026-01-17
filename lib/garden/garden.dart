import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plants_page.dart';
import 'tasks_page.dart';
import '../../colors.dart';
class Garden extends StatefulWidget {
  const Garden({super.key});

  @override
  State<Garden> createState() => _GardenState();
}

class _GardenState extends State<Garden> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: green, 
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 200, 210, 185).withOpacity(0.9),
                  const Color.fromARGB(255, 229, 187, 233).withOpacity(0.7),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),

          // المحتوى الرئيسي
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70, right: 30, left: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTab(
                      title: "مهامي",
                      isSelected: selectedIndex == 0,
                      onTap: () => setState(() => selectedIndex = 0),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      width: 1.5,
                      height: 28,
                      color: const Color.fromARGB(255, 233, 227, 227).withOpacity(0.3),
                    ),
                    const SizedBox(width: 18),
                    _buildTab(
                      title: "نباتاتي",
                      isSelected: selectedIndex == 1,
                      onTap: () => setState(() => selectedIndex = 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // المستطيل الأبيض 
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color (0xFFF6FAF7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(70),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: lavender.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(-8, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, right: 25, left: 25),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: selectedIndex == 0
                          ? const TasksPage(key: ValueKey(1))
                          : const PlantsPage(key: ValueKey(2)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: GoogleFonts.tajawal(
          fontSize: isSelected ? 26 : 23,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: isSelected ?  lavender:const Color.fromARGB(255, 104, 102, 104) ,
          letterSpacing: 0.5,
        ),
        child: Text(title),
      ),
    );
  }
}