class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final bool isOnline;
  final List<String> friends;
  final List<String> friendRequests;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.isOnline = false,
    this.friends = const [],
    this.friendRequests = const [],
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
      friends: json['friends'] != null ? List<String>.from(json['friends']) : [],
      friendRequests: json['friendRequests'] != null ? List<String>.from(json['friendRequests']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'friends': friends,
      'friendRequests': friendRequests,
    };
  }
}
