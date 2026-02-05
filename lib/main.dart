import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import file navigasi utama (Controller)
import 'navigasi_controller.dart'; 
// Import screens
import 'screens/login.dart';
import 'screens/splash_screen.dart';
void main() async {
  // 1. Pastikan binding widget sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase (Gunakan URL dan Anon Key dari project Supabase)
  await Supabase.initialize(
    url: 'https://atozxtqbyjfrnogijbpa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0b3p4dHFieWpmcm5vZ2lqYnBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1OTk0MTIsImV4cCI6MjA4NDE3NTQxMn0.vnZiOjHhKFwWWEklCxYEjqB2AWMTL5ytZalTPx0C9_w', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LabifyBr',
      // Gunakan Splash Screen sebagai pintu awal untuk cek session
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const NavigationController(),
      },
    );
  }
}