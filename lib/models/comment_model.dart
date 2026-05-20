import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String content;
  final UserModel author;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      content: json['content'] ?? '',
      author: UserModel.fromJson(json['author'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
