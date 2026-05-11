// Trong Java, bạn gọi đây là Entity hoặc DTO (Data Transfer Object).
// Ở Flutter/Dart, chúng ta thường gọi nó là Model.

class UserModel {
  // 1. DART FUNDAMENTALS & NULL SAFETY
  // - final: Giống 'final' trong Java hoặc 'readonly' trong C#. 
  //   Nghĩa là giá trị không thể thay đổi sau khi khởi tạo (Immutability).
  // - int, String: Là các kiểu dữ liệu cơ bản (Dart tự động phân biệt object và primitive ở dưới nền).
  
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  
  // - Dấu chấm hỏi (?) biểu thị "Null Safety". 
  //   String? nghĩa là biến này có thể chứa giá trị chuỗi HOẶC có thể mang giá trị null.
  //   Nếu không có dấu ?, Dart bắt buộc biến phải luôn có giá trị.
  final String? avatarUrl; 

  // 2. CONSTRUCTORS & NAMED PARAMETERS
  // Dart hỗ trợ "Named Parameters" bằng cách bọc tham số trong dấu ngoặc nhọn {}.
  // Khi dùng named parameters, nếu biến không cho phép null (không có ?), bạn BẮT BUỘC phải dùng từ khóa 'required'.
  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.avatarUrl, // Tham số này có thể null nên không cần 'required'
  });

  // 3. ARROW FUNCTION & GETTER
  // Dart cho phép tạo các "getter" (giống như property trong C#) cực kỳ ngắn gọn bằng cú pháp => (arrow function).
  // Nó tương đương với: String get fullName { return '$firstName $lastName'; }
  // Ký hiệu $ dùng để chèn biến thẳng vào String (String Interpolation) - rất tiện lợi.
  String get fullName => '$firstName $lastName';
}
