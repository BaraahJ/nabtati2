import 'package:flutter/material.dart';
import '../../../colors.dart';

class CommentsPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = ['جميلة جدًا 🌸', 'ما شاء الله!'];

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, _commentController.text.trim());
      _commentController.clear();
    });

    //    بعدين Firebase عشان 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightpink,
      appBar: AppBar(
        title: const Text('التعليقات', style: TextStyle(color: textColor)),
        backgroundColor: purble,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'مستخدم',
                    style: const TextStyle(
                        color: textColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_comments[index],
                      style: const TextStyle(color: textColor)),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: purble,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقًا...',
                      filled: true,
                      fillColor: white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: lavender),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
