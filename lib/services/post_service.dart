import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(PostModel post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toJson());
  }

  Future<List<PostModel>> fetchPosts() async {
    final querySnapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PostModel.fromJson(doc.data()))
        .toList();
  }
}
