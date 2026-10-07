import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/exceptions.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isStaff => _currentUser?.isStaff ?? false;
  bool get isPrincipal => _currentUser?.isPrincipal ?? false;

  AuthProvider() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    AuthService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> checkAuthState() async {
    _setLoading(true);
    
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        await _loadUserProfile(user.uid);
      }
    } catch (e) {
      _setError('Failed to check authentication state');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final userProfile = await AuthService.getCurrentUserProfile();
      _currentUser = userProfile;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user profile');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phoneNumber,
    String? department,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await AuthService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
        department: department,
      );
      
      _currentUser = user;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during sign up');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await AuthService.signIn(
        email: email,
        password: password,
      );
      
      _currentUser = user;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during sign in');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await AuthService.signOut();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.resetPassword(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send password reset email');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}