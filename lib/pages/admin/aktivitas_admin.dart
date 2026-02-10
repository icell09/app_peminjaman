import 'package:flutter/material.dart';
import '../../services/aktivitas_service.dart';

/// =========================
/// HALAMAN LOG AKTIVITAS
/// =========================
class AktivitasAdmin extends StatefulWidget {
  const AktivitasAdmin({super.key});

  @override
  State<AktivitasAdmin> createState() => _AktivitasAdminState();
}

class _AktivitasAdminState extends State<AktivitasAdmin> {
  /// Instance service
  final AktivitasService _service = AktivitasService();

  /// State loading
  bool loading = true;

  /// Semua data log
  List<Map<String, dynamic>> allLogs = [];

  /// Query pencarian
  String query = '';

  /// Dipanggil pertama kali saat halaman dibuka
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  /// LOAD DATA LOG
  Future<void> _loadLogs() async {
    try {
      final data = await _service.fetchLogs();
      setState(() {
        allLogs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
        children: [
          /// =========================
          /// HEADER BIRU
          /// =========================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0061CD),
                borderRadius: BorderRadius.circular(20),  
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Aktivitas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Riwayat aktivitas pengguna pada aplikasi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// =========================
          /// LIST LOG
          /// =========================
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadLogs,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allLogs.length,
                      itemBuilder: (context, index) {

                        /// Ambil data
                        final item = allLogs[index];
                        final nama =
                            (item['nama'] ?? 'Pengguna').toString();
                        final aktivitas =
                            (item['aktivitas'] ?? '').toString();

                        /// Parsing created_at
                        DateTime? createdAt;
                        try {
                          createdAt = DateTime.parse(
                              item['created_at'].toString());
                        } catch (_) {}

                        /// Format tanggal & waktu
                        final tanggal = createdAt == null
                            ? '-'
                            : _service.formatDateDMY(createdAt);

                        final waktu = createdAt == null
                            ? ''
                            : _service.timeAgo(createdAt);

                        return LogCard(
                          title:
                              '$nama melakukan $aktivitas',
                          subtitle:
                              '$tanggal | $waktu',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }


/// CARD LOG AKTIVITAS
class LogCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LogCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      /// Layout horizontal: icon + teks
      child: Row(
        children: [
          /// Icon notifikasi
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0061CD).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications,
              color: Color(0xFF0061CD),
            ),
          ),
          const SizedBox(width: 12),

          /// Text log
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
