import 'user_model.dart';

// KIẾN THỨC MỚI: Interface (implements)
// Trong Dart, mọi class đều có thể làm Interface. Ở đây ta định nghĩa một hành vi "Bấm được".
abstract class Clickable {
  void onClick();
}

// KIẾN THỨC MỚI: Mixin (with)
// Mixin là cách chia sẻ code cực hay mà không cần Kế thừa (tránh đa kế thừa).
// Bất cứ class nào gắn mixin này sẽ có hàm getFormattedTime().
mixin TimeFormatter {
  String getFormattedTime(DateTime time) {
    // Logic rút gọn: hiển thị "Vài phút trước" hoặc "Hôm qua"
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    }
    return '${difference.inHours} giờ trước';
  }
}

// KIẾN THỨC MỚI: abstract class
// Class cha không thể khởi tạo trực tiếp (không thể new BaseNotification()), dùng làm khuôn mẫu.
abstract class BaseNotification with TimeFormatter implements Clickable {
  final int id;
  final UserModel sender; // Người gây ra thông báo (Ví dụ: A đã like bài của bạn)
  final DateTime createdAt;
  final bool isRead;

  BaseNotification({
    required this.id,
    required this.sender,
    required this.createdAt,
    this.isRead = false,
  });

  // KIẾN THỨC MỚI: abstract method
  // Bắt buộc các class con (extends) phải tự định nghĩa thông báo hiển thị chữ gì và icon gì.
  String getMessage();
  String getIconUrl();
}

// KIẾN THỨC MỚI: extends (Kế thừa) và super (gọi constructor cha)
class LikeNotification extends BaseNotification {
  final int postId;

  LikeNotification({
    required int id,
    required UserModel sender,
    required DateTime createdAt,
    required this.postId,
    bool isRead = false,
  }) : super(id: id, sender: sender, createdAt: createdAt, isRead: isRead); // super: đẩy data lên cho class cha

  // Đa hình (Polymorphism): Ghi đè hàm của class cha
  @override
  String getMessage() => '${sender.fullName} đã bày tỏ cảm xúc về bài viết của bạn.';

  @override
  String getIconUrl() => '❤️';

  @override
  void onClick() {
    print('Chuyển hướng đến Bài viết số $postId');
  }
}

class FriendRequestNotification extends BaseNotification {
  FriendRequestNotification({
    required int id,
    required UserModel sender,
    required DateTime createdAt,
    bool isRead = false,
  }) : super(id: id, sender: sender, createdAt: createdAt, isRead: isRead);

  @override
  String getMessage() => '${sender.fullName} đã gửi cho bạn một lời mời kết bạn.';

  @override
  String getIconUrl() => '👥';

  @override
  void onClick() {
    print('Chuyển hướng đến Trang cá nhân của ${sender.username}');
  }
}
