import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../providers/feed_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  bool _isLoading = false;

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Vui lòng đăng nhập lại.');

      // Lấy thông tin user từ Firestore
      UserModel? author = await _userService.getUserProfile(user.uid);
      
      // Fallback nếu profile chưa kip tạo
      author ??= UserModel(
          id: user.uid,
          username: user.email?.split('@')[0] ?? 'User',
          firstName: 'User',
          lastName: '',
        );

      // Tạo ID ngẫu nhiên chuẩn Firebase
      final String postId = FirebaseFirestore.instance.collection('posts').doc().id;

      final newPost = PostModel(
        id: postId,
        content: content,
        author: author,
        createdAt: DateTime.now(),
        hashtags: [],
      );

      await _postService.createPost(newPost);
      
      if (mounted) {
        // Yêu cầu Provider load lại dữ liệu mới từ Firestore
        context.read<FeedProvider>().fetchFeed();
        Navigator.pop(context); // Đóng màn hình đăng bài
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _submitPost,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Bạn đang nghĩ gì?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
