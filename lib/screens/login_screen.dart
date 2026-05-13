import 'package:flutter/material.dart';
import 'feed_screen.dart'; // Màn hình bảng tin sẽ được tạo ở bước tiếp theo

// KIẾN THỨC: StatefulWidget
// Màn hình này cần StatefulWidget vì chúng ta cần xử lý 2 trạng thái:
// 1. Text đang được nhập trong ô input.
// 2. Ẩn/Hiện mật khẩu (đổi icon con mắt).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // KIẾN THỨC MỚI: Form & Input (Tuần 2.2)
  final _formKey = GlobalKey<FormState>(); // Key để validate Form
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // Biến trạng thái để ẩn/hiện password

  // KIẾN THỨC MỚI: Vòng đời dispose (Tuần 2.3)
  // Phải giải phóng bộ nhớ của các Controller khi rời khỏi màn hình này
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Kích hoạt hàm kiểm tra lỗi (validator) của tất cả TextFormField bên trong
    if (_formKey.currentState!.validate()) {
      // KIẾN THỨC MỚI: Snackbar (Tuần 2.2)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công! Đang chuyển hướng...')),
      );

      // KIẾN THỨC MỚI: Navigation (Tuần 2.2)
      // Dùng pushReplacement để chuyển sang FeedScreen và XÓA luôn LoginScreen khỏi lịch sử 
      // (người dùng bấm nút Back điện thoại sẽ thoát app chứ không quay lại Login).
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: Khung sườn cơ bản của 1 màn hình
    return Scaffold(
      body: Center(
        // SingleChildScrollView: Cho phép cuộn khi bàn phím ảo bật lên che khuất màn hình
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Padding (Tuần 2.2)
            child: Form(
              key: _formKey,
              child: Column( // Column: Xếp các Widget theo chiều dọc (Tuần 2.2)
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Kéo giãn các con ra hết chiều ngang
                children: [
                  // Icon mạng xã hội
                  const Icon(Icons.public, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Đăng Nhập',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // Ô nhập Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên đăng nhập',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    // Logic validate (đúng 10 ký tự, chữ đầu viết hoa) được áp dụng tại đây
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tên đăng nhập không được để trống';
                      }
                      if (value.length != 10) {
                        return 'Phải có đúng 10 ký tự';
                      }
                      if (value[0] != value[0].toUpperCase()) {
                        return 'Chữ cái đầu tiên phải viết hoa';
                      }
                      return null; // Hợp lệ
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ô nhập Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Ẩn mật khẩu bằng dấu chấm
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      // Nút ẩn/hiện mật khẩu (IconButton - Tuần 2.2)
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          // KIẾN THỨC MỚI: setState (Tuần 2.3)
                          // Thay đổi giá trị biến _obscurePassword, sau đó gọi setState để UI tự vẽ lại ổ khóa/mở khóa
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mật khẩu không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút bấm đăng nhập (ElevatedButton - Tuần 2.2)
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16)),
                  ),
                  
                  // MỚI: Dialog (Tuần 2.2)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Quên mật khẩu?'),
                            content: const Text('Tính năng khôi phục mật khẩu đang được xây dựng.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('ĐÓNG'),
                              ),
                            ],
                          );
                        },
                      );
                    }, 
                    child: const Text('Quên mật khẩu?'),
                  ),
                  
                  // Nút chuyển sang trang đăng ký (TextButton - Tuần 2.2)
                  TextButton(
                    onPressed: () {}, 
                    child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
