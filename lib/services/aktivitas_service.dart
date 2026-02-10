import 'package:supabase_flutter/supabase_flutter.dart';

/// Service khusus untuk aktivitas / log
/// Semua logika data ditaruh di sini (BEST PRACTICE)
class AktivitasService {
  /// Ambil instance Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  /// =========================
  /// FETCH DATA LOG AKTIVITAS
  /// =========================
  ///
  /// Mengambil data log aktivitas dari tabel `log_aktivitas`
  /// Urutkan dari yang terbaru
  Future<List<Map<String, dynamic>>> fetchLogs() async {
    // Query ke tabel log_aktivitas 
    final res = await _client
        .from('log_aktivitas') // nama tabel
        .select('id_log, id_user, aktivitas, created_at') // kolom tabel
        .order('created_at', ascending: false); // urutkan terbaru

    // Convert ke list of map agar mudah dipakai di UI
    return List<Map<String, dynamic>>.from(res);
  }


  /// =========================
  /// FORMAT "x JAM YANG LALU"
  /// =========================
  ///
  /// Contoh hasil:
  /// - 10 menit yang lalu
  /// - 2 jam yang lalu
  /// - 3 hari yang lalu
  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} detik yang lalu';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    }

    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) {
      return '$weeks minggu yang lalu';
    }

    final months = (diff.inDays / 30).floor();
    if (months < 12) {
      return '$months bulan yang lalu';
    }

    final years = (diff.inDays / 365).floor();
    return '$years tahun yang lalu';
  }

  /// =========================
  /// FORMAT TANGGAL dd-MM-yyyy
  /// =========================
  ///
  /// Contoh: 20-01-2024
  String formatDateDMY(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}-${two(dt.month)}-${dt.year}';
  }
}
