import 'package:flutter/material.dart';
import '../services/pengembalian_service.dart';
import '../core/messege_type.dart';


class PengembalianController extends ChangeNotifier {
  void Function(String message, MessageType type)? onMessage;

  // Service database
  final PengembalianService _service = PengembalianService();

  // Data peminjaman
  List<Map<String, dynamic>> items = [];

  // State UI
  bool loading = false;
  int activeTab = 0;
  String keyword = '';
  String? error;

  // Callback error ke UI
  void Function(String msg)? onError;

  // =========================
  // Load data dari database
  // =========================
  Future<void> load() async {
    try {
      loading = true;
      notifyListeners();

      items = await _service.fetchPeminjaman();
    } catch (e) {
      error = e.toString(); // ⬅️ simpan error
      onMessage?.call("Gagal memuat data", MessageType.error);
    } finally {
      loading = false;
      notifyListeners();
      }
  }

  // Ganti tab filter
  void setTab(int i) {
    activeTab = i;
    notifyListeners();
  }

  // Set keyword pencarian
  void setKeyword(String v) {
    keyword = v.toLowerCase();
    notifyListeners();
  }

  // Cek apakah peminjaman terlambat
  bool isTerlambat(Map<String, dynamic> r) {
    final tenggat = DateTime.parse(r['tgl_kembali_rencana']);
    return DateTime.now().isAfter(tenggat);
  }

  // Range tanggal pinjam
  String rangeTanggal(Map<String, dynamic> r) =>
      "${r['tgl_pinjam']} s/d ${r['tgl_kembali_rencana']}";

  // =========================
  // Data yang sudah difilter
  // =========================
  List<Map<String, dynamic>> get filtered {
    return items.where((r) {
      // Filter berdasarkan tab
      if (activeTab == 2 && r['status'] != 'selesai') return false;
      if (activeTab == 1 && r['status'] != 'pengembalian') return false;
      if (activeTab == 3 && !isTerlambat(r)) return false;

      // Filter keyword
      if (keyword.isNotEmpty) {
        return r['id_user'].toString().contains(keyword);
      }
      return true;
    }).toList();
  }

  mulaiProses(String idPeminjaman) {
    onMessage?.call("Memulai proses pengembalian untuk $idPeminjaman", MessageType.success);
  }

  formatDate(r) {
    final d = DateTime.parse(r);
    return "${d.day}-${d.month}-${d.year}";
  }
}
