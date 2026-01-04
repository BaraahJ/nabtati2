import 'package:flutter/material.dart';
import '../colors.dart';
import 'marketpost.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMarketItem("نبتة صبار", "نبتة جميلة وسهلة العناية", "assets/images/basil.png", "25₪"),
          _buildMarketItem("نبتة لافندر", "رائحتها جميلة ومهدئة للأعصاب", "assets/images/basil.png", "40₪"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lavender,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMarketPostPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMarketItem(String title, String description, String imageUrl, String price) {
    return Card(
      color: white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/basil.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(color: textColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text("السعر: $price",
                      style: const TextStyle(
                          color: lavender, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
