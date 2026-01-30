import 'package:flutter/material.dart';

class PengaturanAdmin extends StatelessWidget {
  const PengaturanAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), backgroundColor: const Color(0xFF0056C1), foregroundColor: Colors.white),
      body: Column(
        children: [
          const ListTile(leading: Icon(Icons.person), title: Text('Profil Admin')),
          const ListTile(leading: Icon(Icons.security), title: Text('Ubah Password')),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar Aplikasi', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Tambahkan logika logout di sini
            },
          ),
        ],
      ),
    );
  }
}