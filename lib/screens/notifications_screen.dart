import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));

    final NotificationService notificationService = NotificationService();
    final UserService userService = UserService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotificationsStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('Bạn chưa có thông báo nào.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isUnread = !notif.isRead;

              return ListTile(
                tileColor: isUnread ? Colors.blue.withOpacity(0.1) : null,
                leading: CircleAvatar(
                  backgroundColor: notif.type == 'like' ? Colors.red[100] : Colors.blue[100],
                  child: Icon(
                    notif.type == 'like' ? Icons.favorite : Icons.person_add,
                    color: notif.type == 'like' ? Colors.red : Colors.blue,
                  ),
                ),
                title: Text(
                  notif.type == 'like' 
                    ? '${notif.senderName} đã thích bài viết của bạn.'
                    : '${notif.senderName} đã gửi lời mời kết bạn.',
                  style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
                ),
                subtitle: Text(timeago.format(notif.createdAt, locale: 'vi')),
                trailing: notif.type == 'friend_request' && isUnread
                    ? ElevatedButton(
                        onPressed: () async {
                          // Đánh dấu đã đọc
                          await notificationService.markAsRead(currentUser.uid, notif.id);
                          // Đồng ý kết bạn
                          await userService.acceptFriendRequest(currentUser.uid, notif.senderId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã kết bạn với ${notif.senderName}')),
                          );
                        },
                        child: const Text('Đồng ý'),
                      )
                    : null,
                onTap: () {
                  if (isUnread) {
                    notificationService.markAsRead(currentUser.uid, notif.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
