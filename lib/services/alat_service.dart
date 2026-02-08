import 'dart:typed_data';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatSupabaseService {
  final SupabaseClient _db = Supabase.instance.client;

  // =====================
  // ALAT
  // =====================
  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await _db
        .from('alat')
        .select('id_alat,nama_alat,stok,id_kategori,gambar,status')
        .order('nama_alat', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> tambahAlat({
    required String namaAlat,
    required int stok,
    required int idKategori,
    required String gambar,
    String status = 'tersedia',
  }) async {
    await _db.from('alat').insert({
      'nama_alat': namaAlat,
      'stok': stok,
      'id_kategori': idKategori,
      'gambar': gambar,
      'status': status,
    });
  }

  Future<void> updateAlat({
    required String idAlat, // uuid string
    required String namaAlat,
    required int stok,
    required int idKategori,
    required String gambar,
    String? status,
  }) async {
    final data = <String, dynamic>{
      'nama_alat': namaAlat,
      'stok': stok,
      'id_kategori': idKategori,
      'gambar': gambar,
    };
    if (status != null) data['status'] = status;

    await _db.from('alat').update(data).eq('id_alat', idAlat);
  }

  Future<void> deleteAlat(String idAlat) async {
    await _db.from('alat').delete().eq('id_alat', idAlat);
  }

  // =====================
  // KATEGORI
  // =====================
  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final res = await _db
        .from('kategori')
        .select('id_kategori,nama_kategori')
        .order('nama_kategori', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  /// IMPORTANT:
  /// jangan pernah kirim id_kategori saat insert
  Future<void> tambahKategori({required String nama}) async {
    await _db.from('kategori').insert({'nama_kategori': nama});
  }

  Future<void> updateKategori({
    required int idKategori,
    required String nama,
  }) async {
    await _db
        .from('kategori')
        .update({'nama_kategori': nama})
        .eq('id_kategori', idKategori);
  }

  Future<void> deleteKategori(int idKategori) async {
    await _db.from('kategori').delete().eq('id_kategori', idKategori);
  }

  // =====================
  // FOTO
  // =====================
  Future<String> uploadFoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeName = filename.isEmpty ? 'foto.jpg' : filename;
    final path = 'alat/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await _db.storage.from('alat-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return _db.storage.from('alat-images').getPublicUrl(path);
  }

  // =====================
  // Helper: map Postgrest error -> pesan singkat
  // =====================
  String prettyDbError(Object e) {
    if (e is PostgrestException) {
      if (e.code == '23505') return 'Data sudah ada (duplikat).';
      return e.message;
    }
    return e.toString();
  }
}
