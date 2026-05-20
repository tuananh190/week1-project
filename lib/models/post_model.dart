import 'user_model.dart';

class PostModel {
  final String id;
  final String content;
  final UserModel author;
  final DateTime createdAt;
  final List<String> hashtags;
  final String? originalPostId;

  int reactionCount;
  int commentCount;
  bool isLiked;
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      author: UserModel.fromJson(json['author'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : [],
      originalPostId: json['originalPostId'],
      reactionCount: json['reactionCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      interestScore: (json['interestScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'hashtags': hashtags,
      'originalPostId': originalPostId,
      'reactionCount': reactionCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'interestScore': interestScore,
    };
  }
}
