import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/notification_model.dart';
import '../services/post_service.dart';
import '../services/notification_service.dart';

class FeedProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get likedPostsCount => _posts.where((post) => post.isLiked).length;

  FeedProvider() {
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedPosts = await _postService.fetchPosts();
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      
      // Tính toán isLiked dựa trên mảng likedBy
      for (var post in fetchedPosts) {
        if (currentUserUid != null) {
          post.isLiked = post.likedBy.contains(currentUserUid);
        }
      }
      
      _posts = fetchedPosts;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) return;

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final isCurrentlyLiked = post.isLiked;

      // 1. Cập nhật giao diện (UI) ngay lập tức để người dùng không phải chờ
      post.isLiked = !isCurrentlyLiked;
      if (post.isLiked) {
        post.reactionCount++;
        post.likedBy.add(currentUserUid);
      } else {
        post.reactionCount--;
        post.likedBy.remove(currentUserUid);
      }
      notifyListeners(); 

      // 2. Gọi API ngầm lưu xuống Firebase
      try {
        await _postService.toggleLikePost(postId, currentUserUid, isCurrentlyLiked);
        
        // 3. Nếu thả tim (không phải hủy) và không phải tự like bài mình thì bắn Notification
        if (!isCurrentlyLiked && post.author.id != currentUserUid) {
          final notif = NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'like',
            senderId: currentUserUid,
            senderName: FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User',
            postId: postId,
            createdAt: DateTime.now(),
          );
          await NotificationService().sendNotification(post.author.id, notif);
        }
      } catch (e) {
        // Nếu lỗi, hoàn tác (rollback) UI lại
        post.isLiked = isCurrentlyLiked;
        if (post.isLiked) {
          post.reactionCount++;
          post.likedBy.add(currentUserUid);
        } else {
          post.reactionCount--;
          post.likedBy.remove(currentUserUid);
        }
        notifyListeners();
        print("Lỗi khi thả tim: $e");
      }
    }
  }
  void incrementCommentCount(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index].commentCount++;
      notifyListeners();
    }
  }
}
