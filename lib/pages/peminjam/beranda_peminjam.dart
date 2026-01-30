import 'package:flutter/material.dart';

class BerandaPeminjam extends StatelessWidget {
  const BerandaPeminjam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Peminjam'),
        backgroundColor: const Color(0xFF0056C1),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 100, color: Color(0xFF0056C1)),
            SizedBox(height: 10),
            Text('Halo Peminjam!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Cari alat yang ingin Anda pinjam hari ini.'),
          ],
        ),
      ),
    );
  }
}