import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'services/session_service.dart';
import 'services/wallet_service.dart';
import 'services/admin_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VERIDIS - Smart Campus Recycling',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF2E7D32),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          if (snapshot.hasData) {
            SessionService().loadUserSessions();
            return FutureBuilder<bool>(
              future: AdminService().isCurrentUserAdmin(),
              builder: (context, adminSnap) {
                if (adminSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Color(0xFF2E7D32),
                    body: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                return adminSnap.data == true
                    ? const AdminShell()
                    : const HomeScreen();
              },
            );
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
