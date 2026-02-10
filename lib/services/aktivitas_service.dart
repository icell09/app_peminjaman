import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AktivitasService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchLogs() async {
    try {
      final response = await _db
          .from('log_aktivitas') //nama tabelmu
          .select('*')
          .order('created_at', ascending: false); // terbaru di atas
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // Hapus aktivitas berdasarkan ID
  Future<void> deleteAktivitas(int id) async {
    final response = await _db
        .from('log_aktivitas') // <-- ubah sesuai nama tabel
        .delete()
        .eq('id', id);
    print(response);
  }
}
