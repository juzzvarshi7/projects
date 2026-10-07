import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/principal_provider.dart';
import 'providers/theme_provider.dart';
import 'services/db_service_json.dart';
import 'services/db_service_firestore.dart';
import 'services/push_service.dart';
import 'screens/login_screen.dart';
import 'screens/staff_screen.dart';
import 'screens/principal_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as fb_options;
import 'dart:io';

// Toggle: switch to true to enable Firestore mode (after configuring Firebase)
const bool USE_FIRESTORE = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseInit = false;
  try {
    // Try to initialize Firebase using generated options (if available)
    await Firebase.initializeApp(
      options: fb_options.DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInit = true;
    print('Firebase initialized.');
  } catch (e) {
    // If firebase_options.dart or native configs are not present, continue with JSON DB.
    print('Firebase initialization failed or not configured. Continuing without Firebase. Error: $e');
  }

  final dbJson = DBServiceJson();
  await dbJson.init();

  // If firestore desired and firebase initialized, ensure Firestore DBService is ready (no blocking right now)
  if (USE_FIRESTORE && firebaseInit) {
    await DBServiceFirestore.instance.init();
  }

  final themeProvider = ThemeProvider();
  await themeProvider.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => PrincipalProvider()),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}): super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PushService().init(context);
    });
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF1B6FE0),
        secondary: const Color(0xFFF2B64B),
      ),
      textTheme: GoogleFonts.nunitoSansTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B6FE0),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF1B6FE0),
        secondary: const Color(0xFFF2B64B),
      ),
      textTheme: GoogleFonts.nunitoSansTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0A3B6E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Principal Scheduler',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeProv.mode,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        StaffScreen.routeName: (_) => const StaffScreen(),
        PrincipalScreen.routeName: (_) => const PrincipalScreen(),
      },
    );
  }
}
