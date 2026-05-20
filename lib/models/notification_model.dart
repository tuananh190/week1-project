class NotificationModel {
  final String id;
  final String type; // 'like', 'friend_request'
  final String senderId;
  final String senderName;
  final String? postId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.postId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      postId: json['postId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'senderId': senderId,
      'senderName': senderName,
      'postId': postId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
