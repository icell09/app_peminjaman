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
      displayList = allAktivitas
          .where((item) => item['status'] == selectedFilter)
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0061D1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Aktivitas', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Kelola aktivitas peminjam dan pengembalian', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // SEARCH & FILTER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari ...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // DROPDOWN FILTER
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  onSelected: (String newValue) {
                    setState(() {
                      selectedFilter = newValue; // Mengupdate filter dan memicu build ulang
                    });
                  },
                  itemBuilder: (context) => [
                    'Semua', 'Pengajuan', 'Pengembalian', 'Aktif', 'Ditolak', 'Selesai'
                  ].map((item) => PopupMenuItem(
                    value: item,
                    child: Text(item),
                  )).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0061D1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined, color: Color(0xFF0061D1), size: 20),
                        const SizedBox(width: 5),
                        Text(selectedFilter, style: const TextStyle(color: Color(0xFF0061D1), fontWeight: FontWeight.w500)),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0061D1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIST AKTIVITAS (Hasil Filter)
          Expanded(
            child: displayList.isEmpty 
              ? const Center(child: Text("Tidak ada data untuk filter ini"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final item = displayList[index];
                    return ActivityCard(
                      name: item['name'],
                      status: item['status'],
                      color: item['color'],
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  const ActivityCard({super.key, required this.name, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    _statusTag(),
                  ],
                ),
                Text(status, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _itemInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
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
            Text('20-12-2025 s/d 25-12-2025', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const Icon(Icons.delete, color: Colors.redAccent, size: 20),
      ],
    );
  }
}