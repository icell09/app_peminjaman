
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatSupabaseService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await _db
        .from('alat')
        .select('id,nama,stok,kategori,gambar,created_at')
        .order('created_at', ascending: false);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<String> uploadFoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final path = 'alat/${DateTime.now().millisecondsSinceEpoch}_$filename';

    await _db.storage.from('alat-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    // bucket public
    return _db.storage.from('alat-images').getPublicUrl(path);
  }

  Future<void> tambahAlat({
    required String nama,
    required int stok,
    required String kategori,
    required String fotoUrl,
  }) async {
    await _db.from('alat').insert({
      'nama': nama,
      'stok': stok,
      'kategori': kategori,
      'gambar': fotoUrl,
    });
  }

  Future<void> updateAlat({
    required String id,
    required String nama,
    required int stok,
    required String kategori,
    required String fotoUrl,
  }) async {
    await _db.from('alat').update({
      'nama': nama,
      'stok': stok,
      'kategori': kategori,
      'gambar': fotoUrl,
    }).eq('id', id);
  }

  Future<void> deleteAlat(String id) async {
    await _db.from('alat').delete().eq('id', id);
  }
}
