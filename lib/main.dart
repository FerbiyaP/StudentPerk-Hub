import 'package:flutter/material.dart';
import 'package:stuentperk_hub/bottom_navigation/home_screen.dart';
import 'package:stuentperk_hub/screens/splash_screen.dart';
import 'package:stuentperk_hub/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://daaopxtjueulwrezqqmo.supabase.co',
    publishableKey: 'sb_publishable_JwpGRzeRnR9Ry_nu6irFmw_M9yZBhQK',
  );

  await AuthService.instance.init();

  runApp(const StudentPerkHub());
}

class StudentPerkHub extends StatelessWidget {
  const StudentPerkHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudentPerk Hub',
      theme: ThemeData(
        primaryColor: const Color(0xFF5B5FEF),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
