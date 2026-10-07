import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:staff_principal_appointments/core/services/appointment_service.dart';
import 'package:staff_principal_appointments/core/models/appointment_model.dart';
import 'package:staff_principal_appointments/core/models/user_model.dart';
import 'package:staff_principal_appointments/core/utils/exceptions.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot, QuerySnapshot])
void main() {
  group('AppointmentService Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocument;
    late MockDocumentSnapshot mockDocumentSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocument = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();
    });

    group('createAppointment', () {
      test('should create appointment successfully', () async {
        // Arrange
        final appointment = AppointmentModel(
          id: 'test-id',
          staffId: 'staff-123',
          principalId: 'principal-456',
          title: 'Test Meeting',
          description: 'Test Description',
          scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        when(mockFirestore.collection('appointments')).thenReturn(mockCollection);
        when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);
        when(mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.id).thenReturn('test-id');
        when(mockDocumentSnapshot.data()).thenReturn(appointment.toFirestore());

        // Act & Assert
        expect(() => AppointmentService.createAppointment(appointment), returnsNormally);
      });

      test('should throw AppointmentException when creation fails', () async {
        // Arrange
        final appointment = AppointmentModel(
          id: 'test-id',
          staffId: 'staff-123',
          principalId: 'principal-456',
          title: 'Test Meeting',
          description: 'Test Description',
          scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        when(mockFirestore.collection('appointments')).thenReturn(mockCollection);
        when(mockCollection.add(any)).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => AppointmentService.createAppointment(appointment),
          throwsA(isA<AppointmentException>()),
        );
      });
    });

    group('updateAppointmentStatus', () {
      test('should update appointment status successfully', () async {
        // Arrange
        const appointmentId = 'test-id';
        const status = AppointmentStatus.accepted;

        when(mockFirestore.collection('appointments')).thenReturn(mockCollection);
        when(mockCollection.doc(appointmentId)).thenReturn(mockDocument);
        when(mockDocument.update(any)).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          () => AppointmentService.updateAppointmentStatus(appointmentId, status),
          returnsNormally,
        );
      });
    });

    group('getUserAppointments', () {
      test('should return user appointments for staff', () async {
        // Arrange
        const userId = 'staff-123';
        const userRole = UserRole.staff;

        when(mockFirestore.collection('appointments')).thenReturn(mockCollection);
        when(mockCollection.where('staffId', isEqualTo: userId)).thenReturn(mockCollection);
        when(mockCollection.orderBy('scheduledDateTime', descending: true)).thenReturn(mockCollection);

        // Act & Assert
        expect(
          () => AppointmentService.getUserAppointments(userId, userRole),
          returnsNormally,
        );
      });

      test('should return user appointments for principal', () async {
        // Arrange
        const userId = 'principal-456';
        const userRole = UserRole.principal;

        when(mockFirestore.collection('appointments')).thenReturn(mockCollection);
        when(mockCollection.where('principalId', isEqualTo: userId)).thenReturn(mockCollection);
        when(mockCollection.orderBy('scheduledDateTime', descending: true)).thenReturn(mockCollection);

        // Act & Assert
        expect(
          () => AppointmentService.getUserAppointments(userId, userRole),
          returnsNormally,
        );
      });
    });
  });
}