import 'user_model.dart';

class PostModel {
  final int id;
  final String content;
  final UserModel author; 
  final DateTime createdAt;
  final List<String> hashtags;
  final int? originalPostId; 
  
  // Chúng ta xóa 'final' ở reactionCount và isLiked vì khi User bấm Like, 
  // ta cần thay đổi hai giá trị này (Mutational State cho StatelessWidget/StatefulWidget).
  int reactionCount;
  int commentCount;
  bool isLiked; // Thêm bool để biết User hiện tại đã like bài này chưa
  
  // double: Mô phỏng "điểm quan tâm" (score) do AI tính toán (đã nhắc tới trong yêu cầu đồ án).
  final double interestScore; 

  PostModel({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.hashtags,
    this.originalPostId,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.interestScore = 0.0,
  });

  // Tương tự, parse dữ liệu JSON từ API
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      author: UserModel.fromJson(json['author']), // Parse lồng nhau (Nested JSON)
      createdAt: DateTime.parse(json['createdAt']), // Ép kiểu String thành DateTime
      hashtags: List<String>.from(json['hashtags']), // Ép kiểu dynamic List thành List<String>
      originalPostId: json['originalPostId'],
      reactionCount: json['reactionCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      interestScore: (json['interestScore'] ?? 0).toDouble(), // Xử lý kiểu double
    );
  }
}
