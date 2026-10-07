import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:staff_principal_appointments/core/services/auth_service.dart';
import 'package:staff_principal_appointments/core/models/user_model.dart';
import 'package:staff_principal_appointments/core/utils/exceptions.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore, UserCredential, User])
void main() {
  group('AuthService Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();
    });

    group('signUp', () {
      test('should create user successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';
        const role = UserRole.staff;

        when(mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.sendEmailVerification()).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          () => AuthService.signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            role: role,
          ),
          returnsNormally,
        );
      });

      test('should throw AuthException when signup fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';
        const role = UserRole.staff;

        when(mockAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        // Act & Assert
        expect(
          () => AuthService.signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            role: role,
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signIn', () {
      test('should sign in user successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        // Act & Assert
        expect(
          () => AuthService.signIn(email: email, password: password),
          returnsNormally,
        );
      });

      test('should throw AuthException when signin fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Act & Assert
        expect(
          () => AuthService.signIn(email: email, password: password),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('resetPassword', () {
      test('should send password reset email successfully', () async {
        // Arrange
        const email = 'test@example.com';

        when(mockAuth.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async => {});

        // Act & Assert
        expect(
          () => AuthService.resetPassword(email),
          returnsNormally,
        );
      });

      test('should throw AuthException when reset fails', () async {
        // Arrange
        const email = 'invalid@example.com';

        when(mockAuth.sendPasswordResetEmail(email: email))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        // Act & Assert
        expect(
          () => AuthService.resetPassword(email),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}