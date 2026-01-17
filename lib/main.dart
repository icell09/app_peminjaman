import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  // 1. Pastikan binding widget sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase dengan URL dan Anon Key proyek Anda
  await Supabase.initialize(
    url: 'https://atozxtqbyjfrnogijbpa.supabase.co', // Ganti dengan URL Supabase Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0b3p4dHFieWpmcm5vZ2lqYnBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1OTk0MTIsImV4cCI6MjA4NDE3NTQxMn0.vnZiOjHhKFwWWEklCxYEjqB2AWMTL5ytZalTPx0C9_w',         // Ganti dengan Anon Key Anda
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Inventory App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to Lab Inventory App'),
        ),
      ),
    );
  }
}