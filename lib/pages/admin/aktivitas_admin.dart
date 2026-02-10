import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/aktivitas_service.dart';

class AktivitasAdmin extends StatefulWidget {
  const AktivitasAdmin({super.key});

  @override
  State<AktivitasAdmin> createState() => _AktivitasAdminState();
}

class _AktivitasAdminState extends State<AktivitasAdmin> {
  String selectedFilter = 'Semua';
  List<Map<String, dynamic>> allAktivitas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAktivitas();
  }

  Future<void> _loadAktivitas() async {
    try {
      final data = await AktivitasService().fetchLogs();
      setState(() {
        allAktivitas = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayList = allAktivitas;
    if (selectedFilter != 'Semua') {
      displayList =
          allAktivitas
              .where((item) => item['status'] == selectedFilter)
              .toList();
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFF0061CD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Aktivitas Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola data peminjaman sekolah dengan mudah',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];

                        // Jika color dari Supabase berupa string, ubah ke Color
                        Color statusColor = Colors.grey;
                        switch (item['status']) {
                          case 'Aktif':
                            statusColor = Colors.green;
                            break;
                          case 'Pengajuan':
                            statusColor = Colors.blue;
                            break;
                          case 'Pengembalian':
                            statusColor = Colors.orange;
                            break;
                          case 'Ditolak':
                            statusColor = Colors.red;
                            break;
                          case 'Selesai':
                            statusColor = Colors.grey;
                            break;
                        }

                        return ActivityCard(
                          name: item['id']?.toString() ?? '',
                          status:
                              item['status']?.toString() ?? 'Tidak diketahui',
                          color: statusColor,
                          itemInfo: item['aktivitas']?.toString() ?? '',
                          tanggalMulai: item['tanggal_mulai']?.toString() ?? '',
                          tanggalSelesai:
                              item['tanggal_selesai']?.toString() ?? '',
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
  final String itemInfo;
  final String tanggalMulai;
  final String tanggalSelesai;

  const ActivityCard({
    super.key,
    required this.name,
    required this.status,
    required this.color,
    required this.itemInfo,
    required this.tanggalMulai,
    required this.tanggalSelesai,
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
        children: [
          const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(itemInfo, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _dateAndAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              '$tanggalMulai s/d $tanggalSelesai',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const Icon(Icons.delete, color: Colors.redAccent, size: 20),
      ],
    );
  }
}
