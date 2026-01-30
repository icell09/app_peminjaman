import 'package:flutter/material.dart';

class PersetujuanPetugas extends StatelessWidget {
  const PersetujuanPetugas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persetujuan'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: const Center(
        child: Icon(Icons.inventory, size: 100, color: Colors.grey),
      ),
    );
  }
}