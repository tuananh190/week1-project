import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'local_storage_service.dart';
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> registerWithEmailPassword(String email, String password, String firstName, String lastName) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user != null) {
      final userModel = UserModel(
        id: cred.user!.uid,
        username: email.split('@')[0],
        firstName: firstName,
        lastName: lastName,
      );
      await UserService().createUserProfile(userModel);

      // Lưu LocalStorage
      await LocalStorageService.saveAccount(email, password, firstName, lastName);
    }
    
    return cred.user;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Lấy thông tin user để lưu LocalStorage
    if (cred.user != null) {
      final userProfile = await UserService().getUserProfile(cred.user!.uid);
      // Dù userProfile có null (do tạo bằng tay trên Firebase) thì vẫn lưu LocalStorage
      await LocalStorageService.saveAccount(
        email.trim(), 
        password.trim(), 
        userProfile?.firstName ?? email.split('@')[0], 
        userProfile?.lastName ?? '',
      );
    }

    return cred;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
