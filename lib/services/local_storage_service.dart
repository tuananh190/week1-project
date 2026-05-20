import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAccount {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SavedAccount({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';
  String get initials => firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }
}

class LocalStorageService {
  static const String _savedAccountsKey = 'saved_accounts';

  // Lưu một tài khoản mới (hoặc cập nhật nếu đã tồn tại)
  static Future<void> saveAccount(String email, String password, String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Đọc danh sách hiện tại
    final List<SavedAccount> accounts = await getSavedAccounts();
    
    // Kiểm tra xem email này đã có chưa
    final existingIndex = accounts.indexWhere((acc) => acc.email == email);
    final newAccount = SavedAccount(
      email: email, 
      password: password, 
      firstName: firstName, 
      lastName: lastName
    );

    if (existingIndex >= 0) {
      accounts[existingIndex] = newAccount; // Cập nhật mật khẩu/tên nếu có thay đổi
    } else {
      accounts.add(newAccount); // Thêm mới
    }

    // Mã hóa thành JSON và lưu lại
    final List<String> jsonList = accounts.map((acc) => jsonEncode(acc.toJson())).toList();
    await prefs.setStringList(_savedAccountsKey, jsonList);
  }

  // Đọc danh sách tài khoản đã lưu
  static Future<List<SavedAccount>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_savedAccountsKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) => SavedAccount.fromJson(jsonDecode(jsonStr))).toList();
  }

  // Tùy chọn: Xóa một tài khoản khỏi danh sách
  static Future<void> removeAccount(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final List<SavedAccount> accounts = await getSavedAccounts();
    
    accounts.removeWhere((acc) => acc.email == email);
    
    final List<String> jsonList = accounts.map((acc) => jsonEncode(acc.toJson())).toList();
    await prefs.setStringList(_savedAccountsKey, jsonList);
  }
}
