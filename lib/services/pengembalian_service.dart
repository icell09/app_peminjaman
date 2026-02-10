import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianService {
  final SupabaseClient _db = Supabase.instance.client;

  // =========================
  // Ambil data peminjaman untuk halaman pengembalian
  // - case-insensitive karena status kamu campur: Dipinjam / dipinjam, dikembalikan, dll
  // =========================
  Future<List<Map<String, dynamic>>> fetchPeminjaman() async {
    try {
      final res = await _db
          .from('peminjaman')
          .select(
            'id_peminjaman, id_user, tgl_pinjam, tgl_kembali_rencana, status, tgl_kembali_real, denda',
          )
          // ambil hanya yang masih proses pengembalian
          .or('status.ilike.%dipinjam%,status.ilike.%dikembalikan%')
          .order('tgl_pinjam', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('fetchPeminjaman error: $e');
    }
  }

  // =========================
  // Mulai proses pengembalian
  // - saat tombol "Proses Pengembalian" ditekan
  // =========================
  Future<void> mulaiProses(String idPeminjaman) async {
    try {
      await _db
          .from('peminjaman')
          .update({'status': 'dikembalikan'})
          .eq('id_peminjaman', idPeminjaman);
    } catch (e) {
      throw Exception('mulaiProses error: $e');
    }
  }

  // =========================
  // Simpan pengembalian + denda
  // - simpan langsung ke tabel peminjaman (tanpa tabel pengembalian)
  // =========================
  Future<void> simpanPengembalian({
    required String idPeminjaman,
    required DateTime tglKembaliReal, // gabungan tanggal + jam
    required int terlambatHari,
    required int denda, required DateTime tglKembali, required String jamKembali,
  }) async {
    try {
      await _db
          .from('peminjaman')
          .update({
            'tgl_kembali_real': tglKembaliReal.toUtc().toIso8601String(),
            'denda': denda,
            'status': 'selesai',
          })
          .eq('id_peminjaman', idPeminjaman);
    } catch (e) {
      throw Exception('simpanPengembalian error: $e');
    }
  }
}
