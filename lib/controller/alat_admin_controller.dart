import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';
import '../../../services/alat_service.dart';

/// Controller khusus untuk halaman Alat Admin
/// - Menyimpan state
/// - Menangani logic bisnis
/// - Menghubungkan UI ↔ Service (DB)
class AlatAdminController extends ChangeNotifier {
  /// Service database (Supabase)
  final AlatSupabaseService svc;

  AlatAdminController({required this.svc});

  // =========================
  // STATE UI
  // =========================

  /// Text pencarian
  String searchQuery = "";

  /// true = tab Alat, false = tab Kategori
  bool isAlatTab = true;

  /// Loading global halaman
  bool loading = true;

  /// ID kategori yang dipilih untuk filter
  /// null = semua kategori
  int? selectedKategoriId;

  /// Data kategori dari database
  List<Map<String, dynamic>> kategoriDb = [];

  /// Data alat dari database
  List<Map<String, dynamic>> allAlat = [];

  // =========================
  // LOAD DATA
  // =========================

  /// Load semua data (kategori + alat)
  Future<void> loadAll() async {
    loading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadKategori(),
        loadAlat(),
      ]);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Ambil data kategori dari database
  Future<void> loadKategori() async {
    final data = await svc.fetchKategori();

    kategoriDb = [
      for (var e in data)
        {
          'id_kategori': (e['id_kategori']).toInt(),
          'nama_kategori': e['nama_kategori'] as String,
        },
    ];

    notifyListeners();
  }

  /// Ambil data alat dari database
  Future<void> loadAlat() async {
    final data = await svc.fetchAlat();

    allAlat = [
      for (var e in data)
        {
          'id_alat': e['id_alat'],
          'nama_alat': e['nama_alat'],
          'stok': (e['stok']).toInt(),
          'id_kategori': (e['id_kategori'])?.toInt(),
          'gambar': e['gambar'],
          'status': e['status'],
        },
    ];

    notifyListeners();
  }

  // =========================
  // HELPER / UTIL
  // =========================

  /// Convert id_kategori → nama kategori
  String kategoriIdToName(int? id) {
    if (id == null) return "Uncategorized";

    final k = kategoriDb.firstWhere(
      (e) => (e['id_kategori'] as int) == id,
      orElse: () => {},
    );

    return (k['nama_kategori'] as String?) ?? "Uncategorized";
  }

  /// Hitung jumlah alat dalam satu kategori
  int countToolsByCategoryId(int idKategori) {
    return allAlat
        .where((a) => (a['id_kategori'] as int?) == idKategori)
        .length;
  }

  /// List alat yang sudah difilter
  /// - berdasarkan search
  /// - berdasarkan kategori
  List<Map<String, dynamic>> get filteredAlat {
    return allAlat.where((item) {
      final matchesSearch = (item['nama_alat'] as String)
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchesKategori =
          selectedKategoriId == null ||
          (item['id_kategori'] as int?) == selectedKategoriId;

      return matchesSearch && matchesKategori;
    }).toList();
  }

  // =========================
  // UPDATE STATE DARI UI
  // =========================

  /// Update text pencarian
  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  /// Pindah tab (Alat / Kategori)
  void setTab(bool alatTab) {
    isAlatTab = alatTab;
    notifyListeners();
  }

  /// Set kategori filter
  void setSelectedKategori(int? id) {
    selectedKategoriId = id;
    notifyListeners();
  }

  // =========================
  // CRUD ALAT
  // =========================

  /// Tambah alat baru
  Future<void> tambahAlat({
    required String nama,
    required int stok,
    required int kategoriId,
    required Uint8List fotoBytes,
    required String fotoFilename,
  }) async {
    // Upload foto ke storage
    final gambar = await svc.uploadFoto(
      bytes: fotoBytes,
      filename: fotoFilename,
    );

    // Insert data alat
    await svc.tambahAlat(
      namaAlat: nama,
      stok: stok,
      idKategori: kategoriId,
      gambar: gambar,
    );

    // Reload data alat
    await loadAlat();
  }

  /// Update data alat
  Future<void> updateAlat({
    required String idAlat,
    required String nama,
    required int stok,
    required int kategoriId,
    Uint8List? newFotoBytes,
    String? newFotoFilename,
    required String gambarSebelumnya,
  }) async {
    String gambarFinal = gambarSebelumnya;

    // Jika user mengganti foto → upload baru
    if (newFotoBytes != null) {
      gambarFinal = await svc.uploadFoto(
        bytes: newFotoBytes,
        filename: newFotoFilename ?? 'foto.jpg',
      );
    }

    await svc.updateAlat(
      idAlat: idAlat,
      namaAlat: nama,
      stok: stok,
      idKategori: kategoriId,
      gambar: gambarFinal,
    );

    await loadAlat();
  }

  /// Hapus alat
  Future<void> deleteAlat(String idAlat) async {
    await svc.deleteAlat(idAlat);
    await loadAlat();
  }

  // =========================
  // CRUD KATEGORI
  // =========================

  /// Cek apakah nama kategori sudah ada (case-insensitive)
  bool kategoriNameExists(String name, {int? exceptId}) {
    final lower = name.trim().toLowerCase();

    return kategoriDb.any((k) {
      final id = k['id_kategori'] as int;
      final nama = (k['nama_kategori'] as String).toLowerCase();

      if (exceptId != null && id == exceptId) return false;
      return nama == lower;
    });
  }

  /// Tambah kategori baru
  Future<void> tambahKategori(String name) async {
    final v = name.trim();
    if (v.isEmpty) return;

    if (kategoriNameExists(v)) {
      throw Exception("DUPLIKAT_KATEGORI");
    }

    try {
      await svc.tambahKategori(nama: v);
      await loadKategori();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception("DUPLIKAT_KATEGORI");
      }
      rethrow;
    }
  }

  /// Update kategori
  Future<void> updateKategori(int id, String newName) async {
    final v = newName.trim();
    if (v.isEmpty) return;

    if (kategoriNameExists(v, exceptId: id)) {
      throw Exception("DUPLIKAT_KATEGORI");
    }

    await svc.updateKategori(idKategori: id, nama: v);
    await loadKategori();
  }

  /// Hapus kategori
  Future<void> deleteKategori(int id) async {
    await svc.deleteKategori(id);

    // Reset filter jika kategori aktif dihapus
    if (selectedKategoriId == id) {
      selectedKategoriId = null;
    }

    await Future.wait([
      loadKategori(),
      loadAlat(),
    ]);
  }
}
