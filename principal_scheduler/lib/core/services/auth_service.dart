import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../config/app_config.dart';
import '../utils/exceptions.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  
  // Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign up with email and password
  static Future<UserModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phoneNumber,
    String? department,
  }) async {
    try {
      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw AuthException('Failed to create user account');
      }
      
      // Create user profile in Firestore
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
        department: department,
        createdAt: DateTime.now(),
      );
      
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());
      
      // Send email verification
      await userCredential.user!.sendEmailVerification();
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred during sign up');
    }
  }
  
  // Sign in with email and password
  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check login attempts
      await _checkLoginAttempts(email);
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw AuthException('Failed to sign in');
      }
      
      // Get user profile from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      if (!userDoc.exists) {
        throw AuthException('User profile not found');
      }
      
      final userModel = UserModel.fromFirestore(userDoc);
      
      // Check if user is active
      if (!userModel.isActive) {
        await signOut();
        throw AuthException('Account has been deactivated');
      }
      
      // Update last login time
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .update({'lastLoginAt': Timestamp.now()});
      
      // Clear login attempts
      await _clearLoginAttempts(email);
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      await _incrementLoginAttempts(email);
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred during sign in');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw AuthException('Failed to sign out');
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Failed to send password reset email');
    }
  }
  
  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      if (currentUser == null) return null;
      
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (!userDoc.exists) return null;
      
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }
  
  // Update user profile
  static Future<void> updateUserProfile(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toFirestore());
    } catch (e) {
      throw AuthException('Failed to update user profile');
    }
  }
  
  // Check login attempts
  static Future<void> _checkLoginAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'login_attempts_$email';
    final attempts = prefs.getInt(key) ?? 0;
    
    if (attempts >= AppConfig.maxLoginAttempts) {
      throw AuthException('Too many login attempts. Please try again later.');
    }
  }
  
  // Increment login attempts
  static Future<void> _incrementLoginAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'login_attempts_$email';
    final attempts = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, attempts + 1);
  }
  
  // Clear login attempts
  static Future<void> _clearLoginAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'login_attempts_$email';
    await prefs.remove(key);
  }
  
  // Get authentication error message
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An authentication error occurred.';
    }
  }
}