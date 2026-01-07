import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nabtati/search/searchPage.dart';
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
        earnedPoints += 5;
      }
    });
  }

  void resetPoints() {
    setState(() {
      earnedPoints = 0;
    });
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 82, 125, 117) ,
      toolbarHeight: 5,
    ),
    backgroundColor: const Color.fromARGB(255, 82, 125, 117), // نفس لون التوب بار
    body: Column(
      children: [
        Container(
  height: 50,
  padding: const EdgeInsets.symmetric(horizontal: 25),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start, // push to right
    children: [
      Image.asset(
        'assets/images/FINAL-Photoroom.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    ],
  ),
),

       
        // Scrollable Content inside a "white card" with curved left
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              // Card-like background
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100), // منحني من اليسار
                  
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey, 
                    blurRadius: 10, 
                    offset: Offset(-2, 2)
                  )
                ],
              ),
              padding: const EdgeInsets.only(bottom: 100, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: GreetingWidget(),
                  ),
                  PointsCard(
                    totalPoints: totalPoints,
                    earnedPoints: earnedPoints,
                  ),

                  // TEST BUTTONS
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

                  const SizedBox(height: 30),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        buildBox(
                          icon: Icons.search,
                          label: "بحث عن نبتة",
                          color: Colors.white,
                          iconColor: const Color.fromARGB(255, 126, 165, 164),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        buildBox(
                          icon: Icons.bug_report,
                          label: "تشخيص الأمراض",
                          color: Colors.white,
                          iconColor: const Color.fromARGB(255, 109, 171, 100),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تشخيص أمراض النباتات")),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        buildBox(
                          icon: Icons.camera_alt,
                          label: "تعرّف على نبتة",
                          color: Colors.white,
                          iconColor: const Color.fromARGB(255, 158, 131, 174),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlantIdentifierPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


}

// Vertical Button Widget
Widget buildBox({
  required IconData icon,
  required String label,
  required Color color,
  required Color iconColor,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 255, 217, 248),
            color.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withOpacity(0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.9),
                  iconColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 207, 252, 235), size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: iconColor.withOpacity(0.6),
            size: 18,
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