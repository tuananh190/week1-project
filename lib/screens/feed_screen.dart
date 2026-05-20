import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/feed_provider.dart';
import 'create_post_screen.dart';

// Đã biến thành StatelessWidget vì State đã được tách ra Provider
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng tin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // KIẾN THỨC MỚI: Selector (Tuần 3.2)
          // Selector chỉ lắng nghe ĐÚNG MỘT PHẦN nhỏ của Provider.
          // Ở đây, nó chỉ lắng nghe biến `likedPostsCount`. Nếu có post mới nhưng số Like không đổi, 
          // Icon này sẽ KHÔNG bị vẽ lại (Tối ưu hóa cực mạnh).
          Selector<FeedProvider, int>(
            selector: (context, provider) => provider.likedPostsCount,
            builder: (context, count, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    'Đã Thích: $count',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          )
        ],
      ),
      // KIẾN THỨC MỚI: Consumer (Tuần 3.2)
      // Bao bọc vùng giao diện cần thay đổi dữ liệu.
      // Khi FeedProvider gọi notifyListeners(), chỉ vùng bên trong builder này được vẽ lại.
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (feedProvider.errorMessage != null) {
            return Center(child: Text('Lỗi: ${feedProvider.errorMessage}'));
          }

          final posts = feedProvider.posts;
          if (posts.isEmpty) {
             return const Center(child: Text('Chưa có bài viết nào. Hãy là người đầu tiên đăng bài!'));
          }
          
          return ListView(
            children: [
              _buildFriendSuggestionsGrid(), 
              ...posts.map((post) => _buildPostCard(context, post)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  // Thêm context vào tham số vì ta cần dùng context.read()
  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
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
            
            if (post.hashCode % 2 == 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/seed/${post.hashCode}/400/200',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            if (post.hashCode % 2 == 0) const SizedBox(height: 12),
            
            const Divider(), 
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: post.isLiked ? Colors.red : Colors.grey[700],
                  ),
                  icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border),
                  label: Text('${post.reactionCount}'),
                  onPressed: () {
                    // KIẾN THỨC MỚI: context.read (Tuần 3.2)
                    // Cách để lấy hàm từ Provider MÀ KHÔNG LẮNG NGHE thay đổi (không bị rebuild cái nút khi bấm).
                    // Chỉ gửi tín hiệu "Hãy bấm Like đi!" tới Provider.
                    context.read<FeedProvider>().toggleLike(post.id);
                  }, 
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

  Widget _buildFriendSuggestionsGrid() {
    return Container(
      height: 120, 
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, 
          childAspectRatio: 1.0, 
          mainAxisSpacing: 8,
        ),
        itemCount: 5, 
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(height: 4),
                Text('User $index', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
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
