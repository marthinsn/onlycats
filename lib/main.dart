import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'package:onlycats/services/auth_service.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnlyCats',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
