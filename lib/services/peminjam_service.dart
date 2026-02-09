import 'package:flutter/material.dart';

class PeminjamanController extends ChangeNotifier {
  // ============================================================
  // ====================== STATE UTAMA =========================
  // ============================================================

  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;
  TimeOfDay? waktuPinjam;
  TimeOfDay? waktuKembali;

  // ============================================================
  // ================== LIST ALAT DIPILIH =======================
  // ============================================================

  final List<Map<String, dynamic>> alatList;

  // Constructor: salin alat dari beranda
  PeminjamanController(List<Map<String, dynamic>> alatDipilih, {required List<Map<String, String>> allData})
      : alatList =
            alatDipilih.map((a) => {...a, 'qty': a['qty'] ?? 1}).toList();

  // ============================================================
  // ================== MANIPULASI ALAT =========================
  // ============================================================

  /// ➕➖ Tambah / kurangi jumlah alat
  void ubahJumlah(int index, int delta) {
    final current = alatList[index]['qty'] as int;
    final next = current + delta;

    if (next >= 1) {
      alatList[index]['qty'] = next;
      notifyListeners();
    }
  }

  /// ❌ Hapus satu alat
  void hapusAlat(int index) {
    alatList.removeAt(index);
    notifyListeners();
  }

  /// 🗑️ Hapus semua alat sekaligus
  void removeAllAlat() {
    alatList.clear();
    notifyListeners();
  }

  /// 🔍 Apakah masih ada alat
  bool get hasAlat => alatList.isNotEmpty;

  // ============================================================
  // ================== TANGGAL PINJAM ==========================
  // ============================================================

  /// 📅 Set tanggal pinjam
  void setTanggalPinjam(DateTime d) {
    tanggalPinjam = d;

    // Jika tanggal kembali lebih kecil → reset
    if (tanggalKembali != null && tanggalKembali!.isBefore(d)) {
      tanggalKembali = null;
      waktuKembali = null;
    }

    notifyListeners();
  }

  /// 📅 Set tanggal pengembalian
  void setTanggalKembali(DateTime d) {
    tanggalKembali = d;
    notifyListeners();
  }

  /// ✅ Apakah tanggal kembali sudah boleh dipilih
  bool get canPickTanggalKembali => tanggalPinjam != null;

  // ============================================================
  // ================== WAKTU PINJAM ============================
  // ============================================================

  /// ⏰ Set waktu pinjam
  void setWaktuPinjam(TimeOfDay t) {
    waktuPinjam = t;
    notifyListeners();
  }

  /// ⏰ Set waktu pengembalian
  void setWaktuKembali(TimeOfDay t) {
    waktuKembali = t;
    notifyListeners();
  }

  /// ✅ Apakah waktu kembali sudah boleh dipilih
  bool get canPickWaktuKembali => waktuPinjam != null;

  // ============================================================
  // ================== VALIDASI FORM ===========================
  // ============================================================

  /// ✅ Apakah semua field sudah lengkap
  bool get valid =>
      alatList.isNotEmpty &&
      tanggalPinjam != null &&
      tanggalKembali != null &&
      waktuPinjam != null &&
      waktuKembali != null;

  /// 🚀 Shortcut untuk tombol submit
  bool get isReadyToSubmit => valid;

  /// ❗ Pesan error untuk UI
  String? get errorMessage {
    if (alatList.isEmpty) return 'Belum ada alat yang dipilih';
    if (tanggalPinjam == null) return 'Tanggal pinjam belum dipilih';
    if (tanggalKembali == null) return 'Tanggal pengembalian belum dipilih';
    if (waktuPinjam == null) return 'Waktu pinjam belum dipilih';
    if (waktuKembali == null) return 'Waktu pengembalian belum dipilih';
    return null;
  }

  // ============================================================
  // ================== HELPER & HITUNG =========================
  // ============================================================

  /// 🕒 Format TimeOfDay → HH:mm
  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 🧮 Total semua alat (qty)
  int get totalQty =>
      alatList.fold<int>(0, (sum, a) => sum + (a['qty'] as int));

  /// 📆 Ringkasan tanggal (untuk preview UI)
  String get tanggalRangeText {
    if (tanggalPinjam == null || tanggalKembali == null) return '-';
    return '${tanggalPinjam!.day}/${tanggalPinjam!.month}/${tanggalPinjam!.year}'
        ' s/d '
        '${tanggalKembali!.day}/${tanggalKembali!.month}/${tanggalKembali!.year}';
  }

  /// ⏱️ Ringkasan waktu (untuk preview UI)
  String get waktuRangeText {
    if (waktuPinjam == null || waktuKembali == null) return '-';
    return '${_formatTime(waktuPinjam!)} - ${_formatTime(waktuKembali!)}';
  }

  /// 📦 Ringkasan alat (untuk dialog / konfirmasi)
  List<String> getAlatSummary() {
    return alatList
        .map((a) => '${a['nama_alat']} (${a['qty']}x)')
        .toList();
  }

  // ============================================================
  // ================== SUBMIT PEMINJAMAN =======================
  // ============================================================

  /// 🚀 Ajukan peminjaman ke server
  Future<void> ajukanPeminjaman() async {
    if (!valid) {
      throw Exception(errorMessage ?? 'Data belum lengkap');
    }

    final payload = {
      'tanggal_pinjam': tanggalPinjam!.toIso8601String(),
      'tanggal_kembali': tanggalKembali!.toIso8601String(),
      'waktu_pinjam': _formatTime(waktuPinjam!),
      'waktu_kembali': _formatTime(waktuKembali!),
      'total_alat': totalQty,
      'alat': alatList,
    };

    // ===== SIMULASI REQUEST =====
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('📦 PAYLOAD PEMINJAMAN:');
    debugPrint(payload.toString());

    // ===== NANTI GANTI =====
    // Supabase.instance.client.from('peminjaman').insert(payload);
  }

  // ============================================================
  // ================== RESET STATE =============================
  // ============================================================

  /// 🔄 Reset semua data setelah submit berhasil
  void reset() {
    tanggalPinjam = null;
    tanggalKembali = null;
    waktuPinjam = null;
    waktuKembali = null;
    alatList.clear();
    notifyListeners();
  }
}
