import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

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

  Future<void> toggleLikePost(String postId, String userId, bool isCurrentlyLiked) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    if (isCurrentlyLiked) {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'reactionCount': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'reactionCount': FieldValue.increment(1),
      });
    }
  }

  // --- API BÌNH LUẬN ---

  // Lấy danh sách bình luận của 1 bài viết
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromJson(doc.data()))
            .toList());
  }

  // Thêm bình luận mới
  Future<void> addComment(CommentModel comment) async {
    // 1. Lưu comment vào sub-collection 'comments'
    await _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toJson());

    // 2. Tăng số lượng commentCount của bài viết lên 1
    await _firestore.collection('posts').doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }
}
