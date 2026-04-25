import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/rescue_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/admin_rescue_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'package:onlycats/services/auth_service.dart';
import 'package:onlycats/services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // AUTO LOGIN DUMMY
  final auth = AuthService();
  if (auth.currentUser == null) {
    await auth.register('test@mail.com', '123456');
  }

  runApp(const OnlyCatsApp());
}

class OnlyCatsApp extends StatelessWidget {
  const OnlyCatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email;
    final isAdmin = isAdminEmail(email);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnlyCats',
      theme: ThemeData(useMaterial3: true),

      //route awal
      home: isAdmin ? const AdminHomeScreen() : const HomeScreen(),
      //Nama route untuk AdminBottomNav
      routes: {
        '/home': (_) => const HomeScreen(),
        '/rescue': (_) => const RescueScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/admin/home': (_) => const AdminHomeScreen(),
        '/admin/rescue': (_) => const AdminRescueScreen(),
        '/admin/profile': (_) => const AdminProfileScreen(),
      },
    );
  }
}
