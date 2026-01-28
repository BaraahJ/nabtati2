import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nabtati/services/user_service.dart';


class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<_Task> activeTasks = [];
  List<_Task> completedTasks = [];

  /// ✅ كاش للنباتات
  Map<String, Map<String, dynamic>> plantsCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _loadTasks();
  }

  // ================= LOAD TASKS =================
  Future<void> _loadTasks() async {
    final tasks = await _loadTasksFromFirebase();
    final plantIds = tasks.map((t) => t.plantId).toSet();

    for (final id in plantIds) {
      if (!plantsCache.containsKey(id)) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('garden')
            .doc(id)
            .get();

        if (doc.exists) {
          plantsCache[id] = doc.data()!;
        }
      }
    }

    if (mounted) {
      setState(() {
        activeTasks = tasks.where((t) => t.doneAt == null).toList();
        completedTasks = tasks.where((t) => t.doneAt != null).toList();
      });
    }
  }

  Future<List<_Task>> _loadTasksFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .orderBy('dueDate')
        .get();

    return snapshot.docs.map((doc) {
      return _Task(
        id: doc.id,
        plantId: doc['plantId'],
        type: doc['type'],
        dueDate: (doc['dueDate'] as Timestamp).toDate(),
        doneAt: doc['doneAt'] != null
            ? (doc['doneAt'] as Timestamp).toDate()
            : null,
      );
    }).toList();
  }

  // ================= UI =================
  Widget _buildTaskList(List<_Task> tasks, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          isCompleted ? "لا توجد مهام منجزة بعد" : "كل شيء تحت السيطرة ✨",
          style: GoogleFonts.tajawal(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        /// ✅ فحص هل المهمة متأخرة لأكثر من يوم؟
        final bool isOverdue = !isCompleted && 
            DateTime.now().difference(task.dueDate).inHours >= 24;

        final plant = plantsCache[task.plantId];
        if (plant == null) return const SizedBox.shrink();

        final plantName = plant['name'] ?? "نبتة";
        final taskData = plant[task.type];
        final description = taskData != null ? (taskData['description'] ?? '') : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            /// ✅ إضافة برواز أحمر إذا كانت متأخرة
            border: isOverdue 
                ? Border.all(color: Colors.redAccent, width: 1.5) 
                : null,
            boxShadow: [
              BoxShadow(
                color: isOverdue 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              /// SIDE COLOR
              Container(
                width: 6,
                height: 130,
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red : _taskColor(task.type),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Icons.warning_amber_rounded : _taskIcon(task.type),
                            color: isOverdue ? Colors.red : _taskColor(task.type),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _taskTitle(task.type, plantName),
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isOverdue ? Colors.red[900] : Colors.black,
                              ),
                            ),
                          ),
                          if (isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "متأخرة جِداً",
                                style: GoogleFonts.tajawal(color: Colors.white, fontSize: 10),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: isOverdue ? Colors.red : Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(task.dueDate),
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Colors.grey[500],
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              isCompleted
                                  ? Icons.undo_rounded
                                  : Icons.check_circle_rounded,
                              color: isCompleted
                                  ? Colors.orange
                                  : (isOverdue ? Colors.red : Colors.green),
                            ),
                            onPressed: () => isCompleted
                                ? undoCompletion(task)
                                : toggleTaskCompletion(task),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= ACTIONS =================
  void toggleTaskCompletion(_Task task) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(task.id)
        .update({'doneAt': FieldValue.serverTimestamp()});
    await UserService().addPoints(uid: FirebaseAuth.instance.currentUser!.uid, points: 6,
    );

    _loadTasks();
  }
  
 void undoCompletion(_Task task) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(task.id)
        .update({'doneAt': null});
    await UserService().removePoints(FirebaseAuth.instance.currentUser!.uid, 6);

    _loadTasks();
  }

  // ================= HELPERS =================
  String _taskTitle(String type, String name) {
    switch (type) {
      case 'watering': return "ري نبتة $name";
      case 'fertilizing': return "تسميد نبتة $name";
      case 'pruning': return "تقليم نبتة $name";
      default: return name;
    }
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }

  Color _taskColor(String type) {
    switch (type) {
      case 'watering': return Colors.blue;
      case 'fertilizing': return Colors.green;
      case 'pruning': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _taskIcon(String type) {
    switch (type) {
      case 'watering': return Icons.water_drop_rounded;
      case 'fertilizing': return Icons.eco_rounded;
      case 'pruning': return Icons.content_cut_rounded;
      default: return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "مهامي",
          style: GoogleFonts.tajawal(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(161, 138, 183, 1),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromRGBO(161, 138, 183, 1),
          labelColor: const Color.fromRGBO(161, 138, 183, 1),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "المنجزة"),
            Tab(text: "الحالية"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(completedTasks, true),
          _buildTaskList(activeTasks, false),
        ],
      ),
    );
  }
}

class _Task {
  final String id;
  final String plantId;
  final String type;
  final DateTime dueDate;
  final DateTime? doneAt;

  _Task({
    required this.id,
    required this.plantId,
    required this.type,
    required this.dueDate,
    this.doneAt,
  });
}