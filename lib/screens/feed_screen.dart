import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  late Future<List<PostModel>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _postService.fetchPosts();
  }

  // Hàm xử lý việc bấm nút Like cục bộ (Tuần 2.3 - setState)
  void _toggleLike(PostModel post) {
    setState(() {
      post.isLiked = !post.isLiked;
      if (post.isLiked) {
        post.reactionCount++;
      } else {
        post.reactionCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng tin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            
            // Lưới gợi ý bạn bè (Dùng GridView - Tuần 2.2)
            // Lồng nó bên trong ListView chính (sử dụng Column)
            return ListView(
              children: [
                _buildFriendSuggestionsGrid(), // Component con hiển thị lưới
                
                // Trải phẳng danh sách bài viết
                ...posts.map((post) => _buildPostCard(post)),
              ],
            );
          }
          return const Center(child: Text('Trống.'));
        },
      ),
    );
  }

  // Helper method để vẽ một thẻ Bài viết
  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // KIẾN THỨC MỚI: Stack (Tuần 2.2)
                // Dùng Stack để đè chấm xanh (Online) lên trên Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    // Nếu user đang online thì vẽ chấm xanh ở góc dưới bên phải
                    if (post.author.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('@${post.author.username}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
            const SizedBox(height: 12),
            
            // MỚI: Image widget (Tuần 2.2)
            // Hiển thị một hình ảnh ngẫu nhiên nếu bài viết là bài chẵn
            if (post.id % 2 == 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/seed/${post.id}/400/200',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            if (post.id % 2 == 0) const SizedBox(height: 12),
            
            const Divider(), // Đường kẻ ngang
            
            // Hàng nút tương tác
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Like (TextButton kết hợp Icon)
                TextButton.icon(
                  // Nút có màu Đỏ nếu isLiked == true, màu Xám nếu false
                  style: TextButton.styleFrom(
                    foregroundColor: post.isLiked ? Colors.red : Colors.grey[700],
                  ),
                  icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border),
                  label: Text('${post.reactionCount}'),
                  onPressed: () => _toggleLike(post), // Bấm vào sẽ gọi setState
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text('${post.commentCount}'),
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Component phụ mô phỏng GridView (Lưới cuộn ngang) hiển thị Gợi ý kết bạn
  Widget _buildFriendSuggestionsGrid() {
    return Container(
      height: 120, // Chiều cao cố định cho khu vực cuộn ngang
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // 1 hàng
          childAspectRatio: 1.0, // Hình vuông
          mainAxisSpacing: 8,
        ),
        itemCount: 5, // Có 5 người gợi ý
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(height: 4),
                Text('User $index', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                // Nút "Thêm bạn" nhỏ xíu
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: const Size(60, 24),
                  ),
                  child: const Text('Thêm', style: TextStyle(fontSize: 10)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
