import 'package:flutter/material.dart';

class PenggunaAdmin extends StatelessWidget {
  const PenggunaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pengguna'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey),
            Text('Kelola Petugas & Peminjam di sini'),
          ],
        ),
      ),
    );
  }
}