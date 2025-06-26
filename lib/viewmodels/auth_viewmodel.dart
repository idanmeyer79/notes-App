import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signUpWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void clearError() {
    _setError(null);
  }
}
