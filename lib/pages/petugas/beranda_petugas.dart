import 'package:flutter/material.dart';

class BerandaPetugas extends StatelessWidget {
  const BerandaPetugas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Petugas'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: const Center(
        child: Text('Selamat Bekerja, Petugas!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}