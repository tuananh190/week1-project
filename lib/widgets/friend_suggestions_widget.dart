import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

class FriendSuggestionsWidget extends StatelessWidget {
  const FriendSuggestionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser == null) return const SizedBox.shrink();

    final userService = UserService();
    final notificationService = NotificationService();

    return FutureBuilder<UserModel?>(
      future: userService.getUserProfile(currentFirebaseUser.uid),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox.shrink();
        
        final currentUserData = userSnapshot.data!;

        return FutureBuilder<List<UserModel>>(
          future: userService.getStrangers(currentUserData.id, currentUserData.friends),
          builder: (context, strangersSnapshot) {
            if (!strangersSnapshot.hasData || strangersSnapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final strangers = strangersSnapshot.data!;

            return Container(
              height: 140,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: strangers.length,
                itemBuilder: (context, index) {
                  final stranger = strangers[index];
                  // Nếu đã gửi yêu cầu kết bạn rồi thì đổi nút
                  final isSent = stranger.friendRequests.contains(currentUserData.id);

                  return Card(
                    margin: const EdgeInsets.only(left: 12),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stranger.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: isSent
                                ? null
                                : () async {
                                    // 1. Gửi lời mời
                                    await userService.sendFriendRequest(currentUserData.id, stranger.id);
                                    
                                    // 2. Bắn thông báo
                                    final notif = NotificationModel(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      type: 'friend_request',
                                      senderId: currentUserData.id,
                                      senderName: currentUserData.fullName,
                                      createdAt: DateTime.now(),
                                    );
                                    await notificationService.sendNotification(stranger.id, notif);
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã gửi lời mời kết bạn!')),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(60, 24),
                            ),
                            child: Text(isSent ? 'Đã gửi' : 'Thêm bạn', style: const TextStyle(fontSize: 10)),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
