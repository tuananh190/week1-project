import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  // Lấy danh sách người lạ để gợi ý kết bạn
  Future<List<UserModel>> getStrangers(String currentUserId, List<String> friends) async {
    final querySnapshot = await _firestore.collection('users').limit(10).get();
    
    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .where((user) => user.id != currentUserId && !friends.contains(user.id))
        .toList();
  }

  // Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    await _firestore.collection('users').doc(targetUserId).update({
      'friendRequests': FieldValue.arrayUnion([currentUserId])
    });
  }

  // Chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(String currentUserId, String requesterId) async {
    final batch = _firestore.batch();
    
    // 1. Thêm requester vào friends của current, xóa khỏi friendRequests
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    batch.update(currentUserRef, {
      'friends': FieldValue.arrayUnion([requesterId]),
      'friendRequests': FieldValue.arrayRemove([requesterId])
    });

    // 2. Thêm current vào friends của requester
    final requesterRef = _firestore.collection('users').doc(requesterId);
    batch.update(requesterRef, {
      'friends': FieldValue.arrayUnion([currentUserId])
    });

    await batch.commit();
  }
}
