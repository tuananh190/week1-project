import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tạo một instance của PostService để gọi dữ liệu
  final PostService _postService = PostService();

  // Khai báo một Future sẽ nắm giữ danh sách bài viết.
  late Future<List<PostModel>> _postsFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchPosts một lần duy nhất khi màn hình được tạo
    _postsFuture = _postService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng tin (Social Network)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // FutureBuilder: Một widget tuyệt vời của Flutter để xử lý Async Programming trực tiếp trên UI
      body: FutureBuilder<List<PostModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // Xử lý các trạng thái Async:
          
          // 1. Nếu đang chờ dữ liệu (Pending)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          // 2. Nếu có lỗi xảy ra (Error)
          else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          } 
          
          // 3. Nếu thành công và có dữ liệu (Success)
          else if (snapshot.hasData) {
            final posts = snapshot.data!; // Dấu ! báo cho Dart: "Tôi chắc chắn data không null ở dòng này"
            
            // ListView.builder tương tự như RecyclerView trong Android
            // Nó chỉ render các phần tử đang hiển thị trên màn hình để tối ưu RAM
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                
                // Trả về một Card (Thẻ) chứa thông tin bài viết
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gọi Getter 'fullName' từ UserModel
                        Text(
                          post.author.fullName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '@${post.author.username}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(post.content),
                        const SizedBox(height: 8),
                        // Row là một Layout Widget dùng để xếp các thành phần theo chiều ngang
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('❤️ ${post.reactionCount}', style: const TextStyle(color: Colors.red)),
                            Text('💬 ${post.commentCount} bình luận'),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
          
          // Trường hợp fallback cuối cùng
          return const Center(child: Text('Không có bài viết nào.'));
        },
      ),
    );
  }
}
