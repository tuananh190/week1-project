import '../models/post_model.dart';
import '../models/user_model.dart';

// Trong Java/Spring Boot bạn thường đánh dấu class này bằng @Service
// Dart không cần Annotation như vậy để đăng ký, chúng ta chỉ cần tạo class.
class PostService {
  
  // ASYNC PROGRAMMING: Future & async/await
  // Future trong Dart giống như CompletableFuture trong Java hoặc Task trong C#.
  // Nghĩa là: "Hàm này sẽ không trả về kết quả ngay lập tức, mà sẽ trả về một List<PostModel> trong TƯƠNG LAI".
  Future<List<PostModel>> fetchPosts() async {
    // 1. Giả lập thời gian chờ (delay) của Internet / Database Query
    // Dùng 'await' để nói cho hệ thống biết: "Hãy đợi cái Future này hoàn thành rồi mới chạy tiếp dòng lệnh sau".
    await Future.delayed(const Duration(seconds: 2));

    // 2. Control Flow & Operators
    // Mô phỏng logic lấy dữ liệu (Ví dụ: Tạo ra một danh sách rỗng rồi thêm dữ liệu vào)
    List<PostModel> feed = [];
    
    // Tạo user giả định
    UserModel user1 = UserModel(
      id: 1, 
      username: 'Tuananh123', 
      firstName: 'Anh', 
      lastName: 'Nguyen'
    );
    
    UserModel user2 = UserModel(
      id: 2, 
      username: 'Minhdeptrai', 
      firstName: 'Minh', 
      lastName: 'Tran'
    );

    // Dùng For-loop cơ bản (Control Flow) để mô phỏng việc sinh ra 3 bài viết
    for (int i = 0; i < 3; i++) {
      // Dùng if/else (Control Flow) và Operator (==, %)
      UserModel author = (i % 2 == 0) ? user1 : user2; // Toán tử gán điều kiện (Ternary operator)
      
      String content;
      if (i == 0) {
        content = "Hôm nay thời tiết thật đẹp, mình vừa đi chơi ở Hồ Gươm về! #dulich";
      } else if (i == 1) {
        content = "Mọi người thấy trận bóng tối qua thế nào? Kịch tính quá! @Minhdeptrai";
      } else {
        content = "Bắt đầu học Flutter từ con số 0. Rất thú vị! #congnghe #flutter";
      }

      // Thêm dữ liệu vào mảng
      feed.add(
        PostModel(
          id: i + 1,
          content: content,
          author: author,
          createdAt: DateTime.now().subtract(Duration(hours: i * 2)), // Bài cũ hơn
          hashtags: i == 0 ? ['dulich'] : (i == 2 ? ['congnghe', 'flutter'] : []),
          reactionCount: i * 5 + 2,
          commentCount: i * 2,
        )
      );
    }

    return feed;
  }
}
