import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'screens/home_screen.dart';
import 'screens/rescue_screen.dart';
import 'screens/profile_screen.dart';

import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/admin_rescue_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/admin/admin_chat_list_screen.dart';

import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();
  runApp(const OnlyCatsApp());
}

class OnlyCatsApp extends StatelessWidget {
  const OnlyCatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnlyCats',
      theme: ThemeData(useMaterial3: true),

      // route awal: masuk ke splash screen dulu
      home: const SplashScreen(),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),

        '/home': (_) => const HomeScreen(),
        '/rescue': (_) => const RescueScreen(),
        '/profile': (_) => const ProfileScreen(),

        '/admin/home': (_) => const AdminHomeScreen(),
        '/admin/rescue': (_) => const AdminRescueScreen(),
        '/admin/profile': (_) => const AdminProfileScreen(),
        '/admin/chat': (_) => const AdminChatListScreen(),
      },
    );
  }
}
