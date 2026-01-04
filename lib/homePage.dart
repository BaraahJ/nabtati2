import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nabtati/searchPage.dart';
import 'package:nabtati/plantidentifierpage.dart';

class HomeContent extends StatefulWidget {
  final VoidCallback? onSearchPressed;

  const HomeContent({this.onSearchPressed, super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int earnedPoints = 15;
  final int totalPoints = 50;

  void addPoints() {
    setState(() {
      if (earnedPoints < totalPoints) {
        earnedPoints += 5; // Add 5 points each time
      }
    });
  }

  void resetPoints() {
    setState(() {
      earnedPoints = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: GreetingWidget(),
            ),
            PointsCard(
              totalPoints: totalPoints,
              earnedPoints: earnedPoints,
            ),
            
            // TEST BUTTONS - Remove these after testing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: addPoints,
                    icon: const Icon(Icons.add),
                    label: const Text("أضف نقاط (+5)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: resetPoints,
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة تعيين"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // END TEST BUTTONS
            
            const SizedBox(height: 30),
            const Text(
              "نبتتي",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "جميع نباتاتك جاهزة لهذا اليوم",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildBox(
                      icon: Icons.bug_report,
                      label: "تشخيص الأمراض",
                      color: const Color(0xFF9FCF8C),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تشخيص أمراض النباتات")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildBox(
                      icon: Icons.camera_alt,
                      label: "تعرّف على نبتة",
                      color: const Color(0xFFA8C88A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantIdentifierPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildBox(
                      icon: Icons.search,
                      label: "بحث عن نبتة",
                      color: const Color(0xFFB8D8B0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// المربعات الثلاثة (تشخيص – تعرّف – بحث)
Widget buildBox({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ويدجت الترحيب
class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour < 12) {
      return "صباحك أخضر كأوراق نبتتك 🌿";
    } else {
      return "أتمنى لك مساءً هادئًا، ونماء دائم لنبتتك 🌙";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.topRight,
        child: Text(
          getGreeting(),
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// كرت النقاط
class PointsCard extends StatelessWidget {
  final int totalPoints;
  final int earnedPoints;

  const PointsCard({
    super.key,
    required this.totalPoints,
    required this.earnedPoints,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (earnedPoints / totalPoints).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "نقاطك",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300, width: 1.5),
                  ),
                  child: Text(
                    "$earnedPoints / $totalPoints",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: MediaQuery.of(context).size.width * progress * 0.85,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
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