import 'package:flutter/material.dart';
import '../../models/market_post_model.dart';
import '../../services/market_service.dart';
import 'market_post_card.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final MarketService _marketService = MarketService();

  String search = '';
  bool showFilters = false;

  final selectedCities = <String>{};
  final selectedCategories = <String>{};

  final cities = [
    'القدس',
    'رام الله',
    'نابلس',
    'الخليل',
    'غزة',
    'جنين',
  ];

  final categories = [
    'ازهار',
    'خضار',
    'اشجار',
    'اعشاب',
    'نباتات داخلية',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [

          /// 🔍 SEARCH + FILTER (NO EXTRA SPACE)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child:TextField(
  decoration: InputDecoration(
    hintText: 'ابحث عن نبات...',
    prefixIcon: const Icon(Icons.search),
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
  onChanged: (v) => setState(() => search = v),
),

                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () =>
                      setState(() => showFilters = !showFilters),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: showFilters
                          ? Colors.green.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: showFilters
                          ? Colors.green
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🎛️ FILTERS (NO KEYBOARD COLLISION)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: showFilters ? 220 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterSection('المدينة', cities, selectedCities),
                  _filterSection('التصنيف', categories, selectedCategories),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          /// 🛒 POSTS
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: StreamBuilder<List<MarketPostModel>>(
                stream: _marketService.getPosts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  var posts = snapshot.data!;

                  posts = posts.where((p) {
                    final matchSearch = p.title
                        .toLowerCase()
                        .contains(search.toLowerCase());
                    final matchCity = selectedCities.isEmpty ||
                        selectedCities.contains(p.city);
                    final matchCat = selectedCategories.isEmpty ||
                        selectedCategories.contains(p.category);
                    return matchSearch &&
                        matchCity &&
                        matchCat;
                  }).toList();

                  if (posts.isEmpty) {
                    return const Center(child: Text('لا توجد نتائج'));
                  }

                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: posts.length,
                    itemBuilder: (_, i) =>
                        MarketPostCard(post: posts[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterSection(
    String title,
    List<String> items,
    Set<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map((e) {
            final active = selected.contains(e);
            return FilterChip(
              label: Text(e),
              selected: active,
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green,
              onSelected: (v) {
                setState(() {
                  v ? selected.add(e) : selected.remove(e);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
