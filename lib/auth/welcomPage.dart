import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nabtati/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = constraints.maxHeight;
          final double screenWidth = constraints.maxWidth;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500, // أقصى عرض للفورم والشاشة الكبيرة
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // Logo
                      Image.asset(
                        'assets/images/FINAL-Photoroom.png',
                        width: screenWidth * 0.6, // متناسب مع العرض
                        height: screenHeight * 0.35, // متناسب مع الارتفاع
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      Text(
                        'رفيقك في عالم النباتات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth < 350 ? 18 : 22,
                          color: const Color.fromARGB(255, 8, 68, 21)
                              .withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.1),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 58, 116, 92),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, screenHeight * 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 12,
                            shadowColor:
                                const Color.fromARGB(255, 138, 47, 125)
                                    .withOpacity(0.6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'متابعة',
                                style: TextStyle(
                                  fontSize: screenWidth < 350 ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
