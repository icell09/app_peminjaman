import 'package:flutter/material.dart';

class PengembalianPetugas extends StatelessWidget {
  const PengembalianPetugas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proses Pengembalian'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: const Center(
        child: Text('Scan QR atau Input Kode untuk Pengembalian'),
      ),
    );
  }
}