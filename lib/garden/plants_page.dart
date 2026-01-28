import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../colors.dart';
import '../services/garden_service.dart';
import '../models/garden_plant_model.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// العنوان


          const SizedBox(height: 15),

          /// البحث + زر زائد (منظر فقط)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "ابحث عن نبتتك...",
                      hintStyle: GoogleFonts.tajawal(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                /// زر زائد شكلي فقط
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: lavender,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// القائمة
          Expanded(
            child: StreamBuilder<List<GardenPlant>>(
              stream: GardenService().getGardenPlants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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

                /// فلترة البحث
                final plants = snapshot.data!
                    .where((plant) =>
                        plant.name
                            .toLowerCase()
                            .contains(searchQuery))
                    .toList();

                if (plants.isEmpty) {
                  return Center(
                    child: Text(
                      "لا يوجد نتائج 🔍",
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];

                    return Dismissible(
                      key: ValueKey(plant.id),
                      direction: DismissDirection.startToEnd,

                      /// خلفية الحذف
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 5,
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      /// تأكيد الحذف
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("حذف النبتة"),
                            content: const Text(
                                "هل أنت متأكد من حذف هذه النبتة؟"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text("إلغاء"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  "حذف",
                                  style:
                                      TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },

                      
                      onDismissed: (direction) async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth
                                .instance.currentUser!.uid)
                            .collection('garden')
                            .doc(plant.id)
                            .delete();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text("تم حذف النبتة 🌱"),
                          ),
                        );
                      },

                      /// كرت النبتة
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            '/garden/details',
                            extra: plant,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius:
                                BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12
                                    .withOpacity(0.08),
                                blurRadius: 8,
                                offset:
                                    const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 18,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  child: Image.network(
                                    plant.imageUrl,
                                    width: 65,
                                    height: 65,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plant.name,
                                        style:
                                            GoogleFonts.tajawal(
                                          fontSize: 20,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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