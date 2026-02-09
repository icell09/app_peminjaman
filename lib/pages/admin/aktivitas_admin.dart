import 'package:flutter/material.dart';

class AktivitasAdmin extends StatefulWidget {
  const AktivitasAdmin({super.key});

  @override
  State<AktivitasAdmin> createState() => _AktivitasAdminState();
}

class _AktivitasAdminState extends State<AktivitasAdmin> {
  // 1. Variabel state untuk menyimpan filter yang dipilih
  String selectedFilter = 'Semua';

  // 2. Data Master (Semua data ada di sini)
  final List<Map<String, dynamic>> allAktivitas = [
    {'name': 'Monica', 'status': 'Aktif', 'color': Colors.green},
    {'name': 'Budi', 'status': 'Pengajuan', 'color': Colors.blue},
    {'name': 'Santi', 'status': 'Pengembalian', 'color': Colors.orange},
    {'name': 'Andi', 'status': 'Ditolak', 'color': Colors.red},
    {'name': 'Rina', 'status': 'Selesai', 'color': Colors.grey},
    {'name': 'Joko', 'status': 'Aktif', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    // 3. Logika Filter: Menyaring data berdasarkan selectedFilter
    List<Map<String, dynamic>> displayList = allAktivitas;
    if (selectedFilter != 'Semua') {
      displayList =
          allAktivitas
              .where((item) => item['status'] == selectedFilter)
              .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
        backgroundColor: const Color(0xFF0056C1),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Riwayat peminjaman dan pengembalian muncul di sini'),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  const ActivityCard({
    super.key,
    required this.name,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications, color: Color(0xFF0061D1), size: 35),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    _statusTag(),
                  ],
                ),
                Text(
                  status,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _itemInfo(),
                const SizedBox(height: 12),
                _dateAndAction(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _itemInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
          SizedBox(width: 8),
          Text('Mouse Logitech (1x)', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _dateAndAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              '20-12-2025 s/d 25-12-2025',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const Icon(Icons.delete, color: Colors.redAccent, size: 20),
      ],
    );
  }
}
