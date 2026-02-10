import 'package:flutter/foundation.dart';
import '../services/beranda_service.dart';

class BerandaController extends ChangeNotifier {
  final BerandaService _db = BerandaService();  // Instance service database

  // ValueNotifier khusus untuk jumlah status (agar UI bisa dengar perubahan)
  final ValueNotifier<Map<String, int>> statusCountsNotifier = ValueNotifier({
    'menunggu': 0,
    'terlambat': 0,
    'dikembalikan': 0,
    'dipinjam': 0,
  });

  // Stream aktivitas real-time (langsung dari service)
  Stream<List<Map<String, dynamic>>> get activityStream => _db.streamRecentActivities();

  // Saat controller dibuat, langsung load data awal
  BerandaController() {
    _loadStatusCounts();
  }

  // Fungsi untuk mengambil jumlah status dari database
  Future<void> _loadStatusCounts() async {
    try {
      final counts = await _db.getStatusCounts();
      statusCountsNotifier.value = counts;  // Update nilai → UI otomatis refresh
    } catch (e) {
      debugPrint('Error load status counts: $e');
    }
  }

  // Fungsi bantu: mengubah tanggal jadi teks relatif ("4 jam yang lalu", dll)
  String getRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} hari yang lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam yang lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit yang lalu';
    return 'Baru saja';
  }

  // Fungsi untuk refresh data secara manual (misal tombol refresh nanti)
  Future<void> refresh() async {
    await _loadStatusCounts();
  }

  @override
  void dispose() {
    statusCountsNotifier.dispose();  // Bersihkan listener
    super.dispose();
  }
}