import 'dart:typed_data';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatSupabaseService {
  final SupabaseClient _db = Supabase.instance.client;

  // alat
  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await _db
        .from('alat')
        .select('id_alat,nama_alat,stok,id_kategori,gambar,status')
        .order('nama_alat', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchAlatWithKategori() async {
    final res = await _db
        .from('alat')
        .select('''
      id_alat,
      nama_alat,
      stok,
      status,
      gambar,
      kategori:id_kategori (
        id_kategori,
        nama_kategori
      )
    ''')
        .order('nama_alat');

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

  // pinjam alat
  Future<void> pinjamAlat({
    required int idAlat,
    required int stokSekarang,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    if (stokSekarang <= 0) {
      throw Exception('Stok habis');
    }

    // simpan ke tabel peminjaman
    await _db.from('peminjaman').insert({
      'id_alat': idAlat,
      'id_user': user.id,
      'status': 'dipinjam',
    });

    // update stok alat
    final stokBaru = stokSekarang - 1;
    final statusAlat = stokBaru == 0 ? 'dipinjam' : 'tersedia';

    await _db
        .from('alat')
        .update({'stok': stokBaru, 'status': statusAlat})
        .eq('id_alat', idAlat);
  }

  // pengembaliana alat
  Future<void> kembalikanAlat({
    required int idPeminjaman,
    required int idAlat,
    required int stokSekarang,
  }) async {
    // update peminjaman
    await _db
        .from('peminjaman')
        .update({
          'status': 'dikembalikan',
          'tanggal_kembali': DateTime.now().toIso8601String(),
        })
        .eq('id_peminjaman', idPeminjaman);

    // update stok alat
    final stokBaru = stokSekarang + 1;
    await _db
        .from('alat')
        .update({'stok': stokBaru, 'status': 'tersedia'})
        .eq('id_alat', idAlat);
  }

  // riwayat peminjaman saya
  Future<List<Map<String, dynamic>>> fetchPinjamanSaya() async {
    final user = _db.auth.currentUser;
    if (user == null) return [];

    final res = await _db
        .from('peminjaman')
        .select('''
      id_peminjaman,
      status,
      tanggal_pinjam,
      alat (
        id_alat,
        nama_alat,
        gambar,
        stok
      )
    ''')
        .eq('id_user', user.id)
        .order('tanggal_pinjam', ascending: false);

    return (res as List).cast<Map<String, dynamic>>();
  }

  // kategori
  Future<List<Map<String, dynamic>>> fetchKategori() async {
    final res = await _db
        .from('kategori')
        .select('id_kategori,nama_kategori')
        .order('nama_kategori', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

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

  // foto
  Future<String> uploadFoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeName = filename.isEmpty ? 'foto.jpg' : filename;
    final path = 'alat/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await _db.storage
        .from('alat-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return _db.storage.from('alat-images').getPublicUrl(path);
  }

  // Helper: map Postgrest error -> pesan singkat
  String prettyDbError(Object e) {
    if (e is PostgrestException) {
      if (e.code == '23505') return 'Data sudah ada (duplikat).';
      return e.message;
    }
    return e.toString();
  }
}

// keranjang peminjaman
class KeranjangPeminjaman {
  final Map<int, int> _data = {};

  void tambah(int idAlat) {
    _data[idAlat] = (_data[idAlat] ?? 0) + 1;
  }

  void kurang(int idAlat) {
    if (!_data.containsKey(idAlat)) return;
    if (_data[idAlat]! <= 1) {
      _data.remove(idAlat);
    } else {
      _data[idAlat] = _data[idAlat]! - 1;
    }
  }

  int get total => _data.values.fold(0, (a, b) => a + b);

  Map<int, int> get items => Map.unmodifiable(_data);

  void clear() => _data.clear();
}

//fungsi pinjam alat
Future<void> pinjamAlat({
  required int idAlat,
  required int stokSekarang,
}) async {
  if (stokSekarang <= 0) {
    throw Exception('Stok habis');
  }

  final stokBaru = stokSekarang - 1;
  final statusBaru = stokBaru == 0 ? 'dipinjam' : 'tersedia';

  final db = Supabase.instance.client;
  await db
      .from('alat')
      .update({'stok': stokBaru, 'status': statusBaru})
      .eq('id_alat', idAlat);
}
