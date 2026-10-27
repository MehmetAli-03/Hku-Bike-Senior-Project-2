import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HKUBikeApp());
}

class HKUBikeApp extends StatelessWidget {
  const HKUBikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HKU BikeShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00875A)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF00875A))),
          );
        }

        final user = snapshot.data;
        if (user != null && user.emailVerified) {
          return const MainNavigation();
        }

        return const LoginPage();
      },
    );
  }
}