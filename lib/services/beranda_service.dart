import 'package:supabase_flutter/supabase_flutter.dart';

class BerandaService {
  // Instance client Supabase (sudah diinisialisasi di main.dart)
  final SupabaseClient _client = Supabase.instance.client;

  // Fungsi untuk menghitung jumlah peminjaman per status
  Future<Map<String, int>> getStatusCounts() async {
    final counts = <String, int>{};
    final statuses = ['menunggu', 'terlambat', 'dikembalikan', 'dipinjam'];

    for (var status in statuses) {
      final res = await _client
          .from('peminjaman')           // Nama table di Supabase
          .select('count(*)')
          .eq('status', status)
          .maybeSingle();               // Ambil satu baris (count)

      counts[status] = (res?['count'] as int?) ?? 0;
    }
    return counts;
  }

  
  // stream menggunakan realtime (otomatis update kalau ada data baru di table log_aktivitas)
  Stream<List<Map<String, dynamic>>> streamRecentActivities({int limit = 5}) {
    return _client
        .from('log_aktivitas')          // Nama table log aktivitas
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)  // Urut dari yang terbaru
        .limit(limit);                  // Maksimal 5 item
  }

  // Fungsi untuk menambahkan log aktivitas baru
  // Dipanggil misalnya saat ada pengajuan, persetujuan, pengembalian, dll
  Future<void> insertActivity(String pesan) async {
    await _client.from('log_aktivitas').insert({'pesan': pesan});
  }
}