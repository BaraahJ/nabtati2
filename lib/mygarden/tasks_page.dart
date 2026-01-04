import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> activeTasks = [
    {
      "title": "سقي نبات الريحان 💧",
      "dueDate": DateTime.now().subtract(const Duration(hours: 5)), 
    },
    {
      "title": "نقل النعناع إلى وعاء أكبر 🪴",
      "dueDate": DateTime.now().add(const Duration(hours: 6)), 
    },
  ];

  List<Map<String, dynamic>> completedTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void toggleTaskCompletion(Map<String, dynamic> task) {
    setState(() {
      activeTasks.remove(task);
      completedTasks.insert(0, task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🎉 أحسنت! تم إنجاز المهمة بنجاح",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: purble,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void undoCompletion(Map<String, dynamic> task) {
    setState(() {
      completedTasks.remove(task);
      activeTasks.insert(0, task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تمت إعادة المهمة إلى مهامي 🔄",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: lavender,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "مهامي",
          style: GoogleFonts.tajawal(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: green,
          labelColor: textColor,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: "المهام المنجزة"),
            Tab(text: "مهامي"),
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

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          isCompleted ? "لم يتم إنجاز أي مهمة بعد 💭" : "🎉 لا توجد مهام حالياً",
          style: GoogleFonts.tajawal(
            fontSize: 18,
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
        final dueDate = task["dueDate"] as DateTime;
        final isLate = DateTime.now().isAfter(dueDate);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              task["title"],
              textAlign: TextAlign.right,
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: textColor,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: isCompleted
                ? IconButton(
                    icon: Icon(Icons.undo, color: textColor, size: 26),
                    onPressed: () => undoCompletion(task),
                  )
                : IconButton(
                    icon: Icon(Icons.circle_outlined, color: green, size: 28),
                    onPressed: () => toggleTaskCompletion(task),
                  ),
            subtitle: !isCompleted && isLate
                ? Text(
                    "⚠️ تأخرت في تنفيذ هذه المهمة",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
