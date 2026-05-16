import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

// KIẾN THỨC MỚI: ChangeNotifier (Tuần 3.1 & 3.2)
// Lớp cơ sở (Base class) cho phép đối tượng này có khả năng "hét lên" (notifyListeners) 
// cho toàn bộ UI biết khi nào dữ liệu bên trong nó bị thay đổi.
class FeedProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Cung cấp dữ liệu ra ngoài (Getter)
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Đếm tổng số bài viết đã được Like (Dành cho Selector trải nghiệm)
  int get likedPostsCount => _posts.where((post) => post.isLiked).length;

  // Hàm khởi tạo sẽ lấy dữ liệu ngay lập tức
  FeedProvider() {
    fetchFeed();
  }

  // Hàm gọi API lấy dữ liệu
  Future<void> fetchFeed() async {
    _isLoading = true;
    _errorMessage = null;
    
    // Gọi hàm báo cho UI biết "Đang load đấy, xoay loading đi"
    // Hàm quan trọng nhất của ChangeNotifier
    notifyListeners();

    try {
      _posts = await _postService.fetchPosts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      // Dữ liệu đã lấy xong (hoặc lỗi), báo UI vẽ lại đi!
      notifyListeners();
    }
  }

  // Hàm Toggle Like chuyển từ feed_screen.dart sang đây
  void toggleLike(int postId) {
    // Tìm bài viết có id tương ứng
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      post.isLiked = !post.isLiked;
      
      if (post.isLiked) {
        post.reactionCount++;
      } else {
        post.reactionCount--;
      }

      // Thay vì setState cục bộ, ta dùng notifyListeners.
      // Khi hàm này gọi, mọi Consumer hoặc Selector đang lắng nghe FeedProvider đều được cấp dữ liệu mới nhất.
      notifyListeners(); 
    }
  }
}
