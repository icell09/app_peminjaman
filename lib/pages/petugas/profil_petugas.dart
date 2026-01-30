import 'package:flutter/material.dart';

class ProfilPetugas extends StatelessWidget {
  const ProfilPetugas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Petugas'),
        backgroundColor: const Color(0xFF0056C1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF0056C1),
              child: Icon(Icons.engineering, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Nama Petugas'),
                    subtitle: Text('Andi Operasional'),
                  ),
                  ListTile(
                    leading: Icon(Icons.badge),
                    title: Text('ID Pegawai'),
                    subtitle: Text('STF-99283'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {},
                child: const Text('Keluar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}