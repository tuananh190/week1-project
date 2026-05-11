import 'user_model.dart';

class PostModel {
  final int id;
  final String content;
  // Liên kết với UserModel giống như quan hệ @ManyToOne trong JPA/Hibernate
  final UserModel author; 
  
  // DateTime là class có sẵn của Dart để xử lý ngày tháng (giống LocalDateTime trong Java)
  final DateTime createdAt;
  
  // List là kiểu mảng cơ bản trong Dart (giống List<String> trong Java/C#).
  // Dùng List<String> thay vì mảng tĩnh String[] vì nó co giãn được.
  final List<String> hashtags;
  
  // Thuộc tính có thể null, dành cho tính năng Share bài viết.
  final int? originalPostId; 
  
  // Các kiểu số đếm (int) có thể thay đổi nên không dùng final nếu bạn muốn update Like ở các bước sau.
  // Nhưng ở ví dụ này, để giữ tính Immutable, ta dùng final.
  final int reactionCount;
  final int commentCount;

  PostModel({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.hashtags,
    this.originalPostId,
    this.reactionCount = 0, // Cung cấp giá trị mặc định là 0 nếu không truyền vào
    this.commentCount = 0,
  });
}
