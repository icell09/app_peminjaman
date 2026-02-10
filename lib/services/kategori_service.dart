import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KategoriService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<void> deleteKategori(int idKategori) async {
    await _db.from('kategori').delete().eq('id_kategori', idKategori);
  }

  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final res = await _db
        .from('kategori')
        .select('id_kategori,nama_kategori')
        .order('nama_kategori', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }
}
