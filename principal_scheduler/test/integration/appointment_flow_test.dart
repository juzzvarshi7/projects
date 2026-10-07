import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:staff_principal_appointments/main.dart' as app;
import 'package:staff_principal_appointments/core/providers/auth_provider.dart';
import 'package:staff_principal_appointments/core/providers/appointment_provider.dart';
import 'package:staff_principal_appointments/core/providers/audio_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Appointment Flow Integration Tests', () {
    testWidgets('Complete appointment creation and management flow', (tester) async {
      // Start the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AppointmentProvider()),
            ChangeNotifierProvider(create: (_) => AudioProvider()),
          ],
          child: const app.MyApp(),
        ),
      );

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test Login Flow
      await _testLoginFlow(tester);

      // Test Appointment Creation
      await _testAppointmentCreation(tester);

      // Test Appointment Management
      await _testAppointmentManagement(tester);

      // Test Calendar View
      await _testCalendarView(tester);

      // Test Profile Management
      await _testProfileManagement(tester);
    });

    testWidgets('Principal appointment approval flow', (tester) async {
      // Start the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AppointmentProvider()),
            ChangeNotifierProvider(create: (_) => AudioProvider()),
          ],
          child: const app.MyApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login as principal
      await _testPrincipalLogin(tester);

      // Test appointment approval
      await _testAppointmentApproval(tester);

      // Test appointment rejection
      await _testAppointmentRejection(tester);
    });
  });
}

Future<void> _testLoginFlow(WidgetTester tester) async {
  // Find login form elements
  final emailField = find.byKey(const Key('email_field'));
  final passwordField = find.byKey(const Key('password_field'));
  final loginButton = find.byKey(const Key('login_button'));

  // Enter credentials
  await tester.enterText(emailField, 'staff@example.com');
  await tester.enterText(passwordField, 'password123');

  // Tap login button
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // Verify navigation to home screen
  expect(find.text('Dashboard'), findsOneWidget);
}

Future<void> _testAppointmentCreation(WidgetTester tester) async {
  // Navigate to create appointment
  final fab = find.byType(FloatingActionButton);
  await tester.tap(fab);
  await tester.pumpAndSettle();

  // Fill appointment form
  await tester.enterText(find.byKey(const Key('title_field')), 'Test Meeting');
  await tester.enterText(find.byKey(const Key('description_field')), 'Test Description');

  // Select principal
  final principalDropdown = find.byKey(const Key('principal_dropdown'));
  await tester.tap(principalDropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dr. Smith - Principal').first);

  // Select date and time
  final dateField = find.byKey(const Key('date_field'));
  await tester.tap(dateField);
  await tester.pumpAndSettle();
  
  // Select tomorrow's date
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  await tester.tap(find.text(tomorrow.day.toString()));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Create appointment
  final createButton = find.byKey(const Key('create_button'));
  await tester.tap(createButton);
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Appointment created successfully'), findsOneWidget);
}

Future<void> _testAppointmentManagement(WidgetTester tester) async {
  // Navigate to appointments tab
  final appointmentsTab = find.text('Appointments');
  await tester.tap(appointmentsTab);
  await tester.pumpAndSettle();

  // Verify appointment list
  expect(find.byType(Card), findsWidgets);

  // Tap on first appointment
  final firstAppointment = find.byType(Card).first;
  await tester.tap(firstAppointment);
  await tester.pumpAndSettle();

  // Verify appointment details screen
  expect(find.text('Appointment Details'), findsOneWidget);

  // Go back
  await tester.pageBack();
  await tester.pumpAndSettle();
}

Future<void> _testCalendarView(WidgetTester tester) async {
  // Navigate to calendar tab
  final calendarTab = find.text('Calendar');
  await tester.tap(calendarTab);
  await tester.pumpAndSettle();

  // Verify calendar widget
  expect(find.byType(TableCalendar), findsOneWidget);

  // Tap on a date
  final dateCell = find.text('15').first;
  await tester.tap(dateCell);
  await tester.pumpAndSettle();

  // Verify date selection
  expect(find.text('Appointments for'), findsOneWidget);
}

Future<void> _testProfileManagement(WidgetTester tester) async {
  // Navigate to profile tab
  final profileTab = find.text('Profile');
  await tester.tap(profileTab);
  await tester.pumpAndSettle();

  // Verify profile screen
  expect(find.text('Profile'), findsOneWidget);

  // Test edit profile
  final editButton = find.byIcon(Icons.edit);
  await tester.tap(editButton);
  await tester.pumpAndSettle();

  // Modify profile
  final phoneField = find.byKey(const Key('phone_field'));
  await tester.enterText(phoneField, '+1234567890');

  // Save changes
  final saveButton = find.text('Save');
  await tester.tap(saveButton);
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Profile updated successfully'), findsOneWidget);
}

Future<void> _testPrincipalLogin(WidgetTester tester) async {
  // Find login form elements
  final emailField = find.byKey(const Key('email_field'));
  final passwordField = find.byKey(const Key('password_field'));
  final loginButton = find.byKey(const Key('login_button'));

  // Enter principal credentials
  await tester.enterText(emailField, 'principal@example.com');
  await tester.enterText(passwordField, 'password123');

  // Tap login button
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // Verify navigation to principal dashboard
  expect(find.text('Principal'), findsOneWidget);
}

Future<void> _testAppointmentApproval(WidgetTester tester) async {
  // Find pending appointment
  final pendingAppointment = find.text('Pending').first;
  await tester.tap(pendingAppointment);
  await tester.pumpAndSettle();

  // Accept appointment
  final acceptButton = find.text('Accept');
  await tester.tap(acceptButton);
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Appointment accepted successfully'), findsOneWidget);
}

Future<void> _testAppointmentRejection(WidgetTester tester) async {
  // Find pending appointment
  final pendingAppointment = find.text('Pending').first;
  await tester.tap(pendingAppointment);
  await tester.pumpAndSettle();

  // Reject appointment
  final rejectButton = find.text('Reject');
  await tester.tap(rejectButton);
  await tester.pumpAndSettle();

  // Enter rejection reason
  final reasonField = find.byType(TextField);
  await tester.enterText(reasonField, 'Schedule conflict');

  // Confirm rejection
  final confirmButton = find.text('Reject').last;
  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Appointment rejected'), findsOneWidget);
}