import 'package:supabase_flutter/supabase_flutter.dart';

class PersetujuanService {
  PersetujuanService({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  static const _table = 'peminjaman';
  static const _pk = 'id_peminjaman';

  /// Ambil peminjaman dengan status MENUNGGU
  Future<List<Map<String, dynamic>>> fetchMenunggu() async {
    try {
      final res = await _db
          .from(_table)
          .select(
            '$_pk, id_user, tgl_pinjam, tgl_kembali_rencana, status, alasan_penolakan',
          )
          .eq('status', 'Diajukan');

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('fetchMenunggu error: $e');
    }
  }

  Future<void> setujui(String id) async {
    try {
      await _db.from(_table).update({
        'status': 'Dipinjam',
        'alasan_penolakan': null,
      }).eq(_pk, id);
    } catch (e) {
      throw Exception('setujui error: $e');
    }
  }

  Future<void> tolak(String id, String alasan) async {
    try {
      await _db.from(_table).update({
        'status': 'ditolak',
        'alasan_penolakan': alasan.trim(),
      }).eq(_pk, id);
    } catch (e) {
      throw Exception('tolak error: $e');
    }
  }
}
