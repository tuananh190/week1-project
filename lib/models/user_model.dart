class UserModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  
  // bool: Thêm thuộc tính kiểu boolean để xác định User có đang online hay không
  final bool isOnline; 

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.isOnline = false, 
  });

  String get fullName => '$firstName $lastName';

  // KIẾN THỨC MỚI: factory constructor, Map, dynamic
  // factory: Một loại constructor đặc biệt, không phải lúc nào cũng tạo ra một vùng nhớ mới.
  // Ở đây dùng để "chế tạo" UserModel từ một cục JSON do Backend trả về.
  // Map<String, dynamic>: Kiểu dữ liệu Key-Value giống Dictionary trong C#.
  // JSON luôn có Key là String (ví dụ "username"), còn Value có thể là chữ, số, mảng nên để là dynamic.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'], // Nếu trong JSON không có avatarUrl, nó sẽ nhận null
      isOnline: json['isOnline'] ?? false, // Toán tử ?? (Null-aware): Nếu vế trước null thì lấy vế sau
    );
  }
}
