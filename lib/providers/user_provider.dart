import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  app_user.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  // Initialize user from auth state
  Future<void> initializeUser() async {
    _setLoading(true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _currentUser = await _authService.getUserById(user.uid);
        if (_currentUser != null) {
          await _authService.updateLastLogin(user.uid);
        }
      }
      _clearError();
    } catch (e) {
      _setError('Failed to initialize user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithEmailAndPassword(email, password);
      if (_currentUser != null) {
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? whatsappNumber,
    required app_user.UserRole role,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        whatsappNumber: whatsappNumber,
        role: role,
      );
      if (_currentUser != null) {
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _clearError();
      return true;
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(app_user.User updatedUser) async {
    _setLoading(true);
    try {
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      try {
        final refreshedUser = await _authService.getUserById(_currentUser!.id);
        if (refreshedUser != null) {
          _currentUser = refreshedUser;
          notifyListeners();
        }
      } catch (e) {
        _setError('Failed to refresh user data: ${e.toString()}');
      }
    }
  }

  // Clear error
  void _clearError() {
    _error = null;
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  // Get user by ID
  Future<app_user.User?> getUserById(String uid) async {
    try {
      return await _authService.getUserById(uid);
    } catch (e) {
      _setError('Failed to get user: ${e.toString()}');
      return null;
    }
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
