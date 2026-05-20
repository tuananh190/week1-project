import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';
import '../providers/feed_provider.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService();
  bool _isSubmitting = false;

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Vui lòng đăng nhập lại.');

      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.postId,
        content: text,
        author: UserModel(
          id: user.uid,
          username: user.email?.split('@')[0] ?? 'user',
          firstName: 'User',
          lastName: '',
        ),
        createdAt: DateTime.now(),
      );

      await _postService.addComment(comment);
      
      // Cập nhật số đếm trên FeedScreen ngay lập tức
      if (mounted) {
        context.read<FeedProvider>().incrementCommentCount(widget.postId);
      }

      _commentController.clear();
      FocusScope.of(context).unfocus(); // Đóng bàn phím
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding để bàn phím không che mất ô nhập liệu
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const Text('Bình luận', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          
          // Danh sách bình luận
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _postService.getCommentsStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text('Lỗi tải bình luận'));
                }

                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('Chưa có bình luận nào.'));
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(comment.author.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.content, style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(
                            timeago.format(comment.createdAt, locale: 'vi'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Ô nhập bình luận
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _submitComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
