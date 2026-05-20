import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách thông báo của một người dùng
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList());
  }

  // Gửi một thông báo mới
  Future<void> sendNotification(String targetUserId, NotificationModel notification) async {
    await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
