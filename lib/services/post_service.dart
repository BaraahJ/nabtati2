import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nabtati/services/user_service.dart';
import '../models/post_model.dart';


class PostService {
  final _postsRef = FirebaseFirestore.instance.collection('posts');

  Stream<List<PostModel>> getPosts() {
    return _postsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PostModel.fromMap(data);
      }).toList();
    });
  }
  

  Future<void> addPost(
    String content,
    String imageUrl,
    String userId,
  ) async {
    await _postsRef.add({
      'content': content,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
      'commentsCount': 0,
    });
    await UserService().addPoints(uid: userId, points: 10);
  }
  
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    await _postsRef.doc(postId).delete();
    await UserService().removePoints(userId, 10);
  }
}
