import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:nabtati/plant/plantDesign.dart';
import 'package:nabtati/services/plant_service.dart';
import 'package:nabtati/models/plant_model.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantIdentifierPage extends StatefulWidget {
  final String renderBaseUrl;
  final void Function(Map<String, dynamic> result)? onResult;

  const PlantIdentifierPage({
    super.key,
    required this.renderBaseUrl,
    this.onResult,
  });

  @override
  State<PlantIdentifierPage> createState() => _PlantIdentifierPageState();
}

class _PlantIdentifierPageState extends State<PlantIdentifierPage> {
  final PlantService _plantService = PlantService();

  final ImagePicker _picker = ImagePicker();
  final List<File> _selected = [];
  bool _loading = false;

  // Colors
  static const Color bg = Color(0xFFEFFAF1);
  static const Color green = Color(0xFF22C55E);
  static const Color greenSoft = Color(0xFFDDF7E5);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMid = Color(0xFF475569);

  // ================= IMAGE PICKING =================

  Future<void> _pickGallery({bool addMore = false}) async {
    if (!addMore) _selected.clear();

    final remain = 3 - _selected.length;
    if (remain <= 0) return;

    final picks = await _picker.pickMultiImage(imageQuality: 92);
    if (picks.isEmpty) return;

    setState(() {
      _selected.addAll(picks.take(remain).map((x) => File(x.path)));
    });
  }

  Future<void> _takePhoto({bool addMore = false}) async {
    if (!addMore) _selected.clear();

    final remain = 3 - _selected.length;
    if (remain <= 0) return;

    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 92);
    if (x == null) return;

    setState(() {
      _selected.add(File(x.path));
    });
  }

  // ✅ اختيار سريع: كاميرا أو معرض (لزر "أضف المزيد")
  void _showAddMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: green),
                title: Text(
                  "التقاط صورة بالكاميرا",
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (!_loading) _takePhoto(addMore: true); // ✅ يضيف
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: green),
                title: Text(
                  "اختيار من المعرض",
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (!_loading) _pickGallery(addMore: true); // ✅ يضيف
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= IDENTIFICATION =================

  String _normalizeDocId(String label) {
    return label.trim().toLowerCase().replaceAll(RegExp(r'[\s\-_]+'), '');
  }

  Future<void> _identify() async {
    if (_selected.isEmpty) return;

    setState(() => _loading = true);

    try {
      final base = widget.renderBaseUrl.trim().replaceAll(RegExp(r'/$'), '');
      final uri = Uri.parse("$base/predict");

      final req = http.MultipartRequest("POST", uri);
      for (final f in _selected) {
        req.files.add(await http.MultipartFile.fromPath("files", f.path));
      }

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode != 200) {
        throw Exception("API ${resp.statusCode}: ${resp.body}");
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      widget.onResult?.call(data);

      if (!mounted) return;
      await _handleResult(data);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleResult(Map<String, dynamic> res) async {
    final labelRaw = (res["label"] ?? "").toString().trim();

    // Unknown -> Dialog فقط
    if (labelRaw.isEmpty || labelRaw.toLowerCase() == "unknown") {
      _showUnknownDialog(res);
      return;
    }

    final docId = _normalizeDocId(labelRaw);

    try {
      final Plant? plant = await _plantService.getPlantById(docId);

      if (!mounted) return;

      if (plant != null) {
        Navigator.of(context).push(_animatedRoute(PlantDesign(plant: plant)));
        return;
      }

      _showNotInDatabaseDialog(labelRaw);
    } catch (_) {
      if (!mounted) return;
      _showUnknownDialog(res);
    }
  }

  // ================= ANIMATION ROUTE =================

  Route _animatedRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

        // ⬅️ من اليسار إلى الوسط
        final slide = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(curved);

        return SlideTransition(position: slide, child: child);
      },
    );
  }

  // ================= DIALOGS (WITH IMAGES) =================

  // 🙂 معروف لكن مش موجود بالداتا بيس
  void _showNotInDatabaseDialog(String label) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Image.asset("assets/emojis/happy.png", width: 28, height: 28),
              const SizedBox(width: 10),
              Text(
                "غير متوفرة حاليًا",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'النبتة هي "$label" ليست متوفرة حاليًا.',
            style: GoogleFonts.tajawal(fontSize: 15.5, height: 1.7),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "موافق",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 😔 لم يتم التعرف
  void _showUnknownDialog(Map<String, dynamic> res) {
    final conf = (res["confidence"] is num) ? (res["confidence"] as num).toDouble() : null;
    final top3 = (res["top3"] is List) ? (res["top3"] as List) : const [];

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Image.asset("assets/emojis/sad.png", width: 28, height: 28),
              const SizedBox(width: 10),
              Text(
                "لم يتم التعرّف",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "لم نتمكن من تحديد نوع النبتة بدقة.",
                style: GoogleFonts.tajawal(fontSize: 14.8, height: 1.7),
              ),
              const SizedBox(height: 10),
              if (conf != null)
                Text(
                  "نسبة الثقة: ${(conf * 100).toStringAsFixed(1)}%",
                  style: GoogleFonts.tajawal(fontSize: 14.3, height: 1.7),
                ),
              const SizedBox(height: 12),
              Text(
                "أفضل النتائج:",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 15.5),
              ),
              const SizedBox(height: 6),
              if (top3.isEmpty)
                Text(
                  "لا توجد نتائج متاحة.",
                  style: GoogleFonts.tajawal(fontSize: 14.5, height: 1.7),
                )
              else
                ...top3.take(3).map((item) {
                  final l = (item["label"] ?? "").toString();
                  final p = (item["prob"] is num) ? (item["prob"] as num).toDouble() : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "• $l — ${(p * 100).toStringAsFixed(1)}%",
                      style: GoogleFonts.tajawal(fontSize: 14.5, height: 1.7),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "نصيحة: جرّب صورة أوضح (ورقة + النبتة كاملة + زهرة/ثمرة) لتحسين النتيجة.",
                  style: GoogleFonts.tajawal(fontSize: 13.6, height: 1.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "موافق",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            "حدث خطأ",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: Text(
            msg,
            style: GoogleFonts.tajawal(fontSize: 14.5, height: 1.7),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "موافق",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final hasPhotos = _selected.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: Column(
                children: [
                  const SizedBox(height: 6),

                  // Top circle icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: greenSoft,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(Icons.search, color: green, size: 28),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "تعرّف على النباتات",
                    style: GoogleFonts.tajawal(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "التقط أو ارفع حتى 3 صور لتحسين الدقة",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(fontSize: 14, color: textMid),
                  ),

                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: !hasPhotos
                          ? const _EmptyStateCard()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "الصور المختارة (${_selected.length}/3)",
                                  style: GoogleFonts.tajawal(
                                    color: textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: _SelectedRow(
                                    files: _selected,
                                    canAddMore: _selected.length < 3,
                                    onRemove: (i) => setState(() => _selected.removeAt(i)),
                                    onAddMore: _showAddMoreSheet,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _BigActionCard(
                          icon: Icons.photo_camera,
                          label: "التقاط صورة",
                          onTap: _loading ? null : () => _takePhoto(addMore: true),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _BigActionCard(
                          icon: Icons.photo_library,
                          label: "المعرض",
                          onTap: _loading ? null : () => _pickGallery(addMore: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  if (hasPhotos)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: _loading ? null : _identify,
                        child: Text(
                          "تعرّف على النبتة",
                          style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.05),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.70),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.local_florist_outlined, size: 56, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "لم يتم اختيار صور بعد",
            style: GoogleFonts.tajawal(color: const Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _BigActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const Color green = Color(0xFF22C55E);
  static const Color greenSoft = Color(0xFFDDF7E5);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 140,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: greenSoft,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(icon, color: green, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedRow extends StatelessWidget {
  final List<File> files;
  final bool canAddMore;
  final void Function(int index) onRemove;
  final VoidCallback onAddMore;

  const _SelectedRow({
    required this.files,
    required this.canAddMore,
    required this.onRemove,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: canAddMore ? files.length + 1 : files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i < files.length) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(files[i], width: 90, height: 90, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: InkWell(
                    onTap: () => onRemove(i),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }

          return InkWell(
            onTap: onAddMore,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color(0xFF22C55E)),
                  const SizedBox(height: 4),
                  Text(
                    "أضف المزيد",
                    style: GoogleFonts.tajawal(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
