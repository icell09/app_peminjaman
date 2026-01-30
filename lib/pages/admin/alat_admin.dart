import 'package:flutter/material.dart';

class AlatAdmin extends StatelessWidget {
  const AlatAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Alat'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.inventory_2, color: Color(0xFF0056C1)),
          title: Text('Nama Alat #${index + 1}'),
          subtitle: const Text('Status: Tersedia'),
          trailing: const Icon(Icons.edit),
        ),
      ),
    );
  }
}