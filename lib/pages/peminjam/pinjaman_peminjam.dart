import 'package:flutter/material.dart';

class PinjamanPeminjam extends StatelessWidget {
  const PinjamanPeminjam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjaman Saya'),
        backgroundColor: const Color(0xFF0056C1),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: 3, // Contoh ada 3 data
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.orange),
            title: Text('Alat #${index + 1}'),
            subtitle: const Text('Status: Sedang Dipinjam'),
            trailing: const Text('12 Jan 2024'),
          ),
        ),
      ),
    );
  }
}