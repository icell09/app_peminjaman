import 'package:flutter/material.dart';

class AktivitasAdmin extends StatelessWidget {
  const AktivitasAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Aktivitas'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: const Center(
        child: Text('Riwayat peminjaman dan pengembalian muncul di sini'),
      ),
    );
  }
}