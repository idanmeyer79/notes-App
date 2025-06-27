import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  AuthViewModel() {
    _authService.authStateChanges.listen((User? user) {
      notifyListeners();
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    return await executeAsync(() async {
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    });
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    return await executeAsync(() async {
      await _authService.signUpWithEmailAndPassword(email, password);
      return true;
    });
  }

  Future<bool> signInWithGoogle() async {
    return await executeAsync(() async {
      await _authService.signInWithGoogle();
      return true;
    });
  }

  Future<void> signOut() async {
    await executeAsync(() async {
      await _authService.signOut();
    });
  }

  Future<bool> resetPassword(String email) async {
    return await executeAsync(() async {
      await _authService.resetPassword(email);
      return true;
    });
  }
}
