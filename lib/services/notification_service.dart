import 'dart:async';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class NotificationService {
  // KIẾN THỨC MỚI: StreamController (Phần lõi của Stream)
  // Khác với Future chỉ trả về 1 kết quả rồi kết thúc, Stream giống như một "đường ống" (Pipe).
  // Bạn đẩy dữ liệu vào 1 đầu, đầu kia (UI) sẽ liên tục nhận được dữ liệu mới (Real-time).
  final StreamController<BaseNotification> _notificationController = StreamController<BaseNotification>.broadcast();

  // Getter để UI có thể lắng nghe luồng dữ liệu (giống Observable)
  Stream<BaseNotification> get notificationStream => _notificationController.stream;

  // Hàm mô phỏng máy chủ liên tục gửi thông báo về cho App
  void startSimulatingNotifications() async {
    var count = 0;
    UserModel mockUser = UserModel(id: 99, username: 'FanCung2026', firstName: 'Fan', lastName: 'Cung');

    // KIẾN THỨC MỚI: do-while và var
    // Dùng do-while để đảm bảo vòng lặp chạy ít nhất 1 lần.
    // Dùng 'var' khi không muốn chỉ định rõ kiểu dữ liệu, Dart sẽ tự suy luận kiểu.
    do {
      await Future.delayed(const Duration(seconds: 3)); // Đợi 3 giây
      
      count++;
      BaseNotification newNotification; // Khai báo bằng BaseNotification

      // KIẾN THỨC MỚI: switch/case
      // Rẽ nhánh logic tùy theo biến count
      switch (count % 2) {
        case 0:
          // Nếu count chẵn, tạo thông báo Like
          newNotification = LikeNotification(
            id: count,
            sender: mockUser,
            createdAt: DateTime.now(),
            postId: 101, // ID bài viết giả định
          );
          break; // Bắt buộc phải có break trong switch/case
        case 1:
          // Nếu count lẻ, tạo thông báo Kết bạn
          newNotification = FriendRequestNotification(
            id: count,
            sender: mockUser,
            createdAt: DateTime.now(),
          );
          break;
        default:
          throw Exception("Lỗi logic không xác định");
      }

      // Đẩy thông báo mới vào ống nước (Stream)
      _notificationController.sink.add(newNotification);
    } while (count < 5);
  }

  // Luôn nhớ dọn dẹp Stream để tránh tràn bộ nhớ (Memory Leak)
  void dispose() {
    _notificationController.close();
  }
}
