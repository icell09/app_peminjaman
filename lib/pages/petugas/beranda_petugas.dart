import 'package:flutter/material.dart';

import '../../controller/beranda_petugas_controller.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BerandaPetugas(),
    ),
  );
}

class BerandaPetugas extends StatefulWidget {
  const BerandaPetugas({super.key});

  @override
  State<BerandaPetugas> createState() => _BerandaPetugasState();
}

class _BerandaPetugasState extends State<BerandaPetugas> {
  late final BerandaController _controller;  // Controller untuk mengatur data & logika

  @override
  void initState() {
    super.initState();
    _controller = BerandaController();  // Inisialisasi controller
  }

  @override
  void dispose() {
    _controller.dispose();  // Bersihkan resource (ValueNotifier dll) saat halaman ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xFF0061D1),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Beranda",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Kelola data peminjaman sekolah dengan mudah",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // welcome card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Selamat Datang,\nPetugas 👋",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Mengatur jarak antar baris teks
                      ),
                    ),
                    // MENGGUNAKAN FOTO DARI ASSET
                    Container(
                      padding: const EdgeInsets.all(
                        2,
                      ), // Jarak antara border dan foto
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0061D1),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFFE3F2FD),
                        // Pastikan path ini sesuai dengan yang ada di pubspec.yaml
                        backgroundImage: AssetImage('assets/images/admin.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // kotak status 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ValueListenableBuilder<Map<String, int>>(
                valueListenable: _controller.statusCountsNotifier,  // Dengarkan perubahan jumlah dari controller
                builder: (context, counts, child) {
                  return Row(
                    children: [
                      Expanded(child: _statusCard(counts['menunggu']!.toString(), "Menunggu\nPersetujuan", const Color(0xFFFFE8E0), const Color(0xFFE65100))),
                      const SizedBox(width: 10),
                      Expanded(child: _statusCard(counts['terlambat']!.toString(), "Terlambat", const Color(0xFFFFE0E0), const Color(0xFFD32F2F))),
                      const SizedBox(width: 10),
                      Expanded(child: _statusCard(counts['dikembalikan']!.toString(), "Dikembalikan", const Color(0xFFE8F5E9), const Color(0xFF2E7D32))),
                      const SizedBox(width: 10),
                      Expanded(child: _statusCard(counts['dipinjam']!.toString(), "Dipinjam", const Color(0xFFE3F2FD), const Color(0xFF1565C0))),
                    ],
                  );
                },
              ),
            ),

            // Judul aktivitas terbaru
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Aktivitas terbaru",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // --- List Aktivitas (real-time) ---
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _controller.activityStream,  // Stream dari controller (yang ambil dari service)
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final activities = snapshot.data ?? [];
                if (activities.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(20), child: Text('Belum ada aktivitas'));
                }

                return Column(
                  children: activities.map((act) {
                    final createdAtRaw = act['created_at'];
    
    String formattedDate = '-';
    String relativeTime = 'waktu tidak diketahui';

    if (createdAtRaw != null && createdAtRaw is String && createdAtRaw.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAtRaw);
        formattedDate = DateFormat('dd-MM-yyyy').format(date);
        relativeTime = _controller.getRelativeTime(date);
      } catch (e) {
        // Jika parsing gagal (format tanggal salah)
        formattedDate = 'Format tanggal salah';
        relativeTime = 'error';
        debugPrint('Gagal parse created_at: $createdAtRaw → $e');
      }
    }

    return _activityTile(
      act['pesan'] as String? ?? 'Aktivitas tidak diketahui',
      '$formattedDate | $relativeTime',
    );
  }).toList(),
);
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Status
  Widget _statusCard(String val, String title, Color bg, Color text) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: text.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2, //batas baris

            style: const TextStyle(
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk List Aktivitas
  Widget _activityTile(String msg, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Color(0xFF0061D1), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

DateFormat(String s) {

}
