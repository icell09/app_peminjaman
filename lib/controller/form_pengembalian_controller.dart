import 'package:flutter/material.dart';
import '../services/pengembalian_service.dart';

// Tipe pesan untuk UI
enum MessageType { success, warning, error }

class FormPengembalianController extends ChangeNotifier {
  final PengembalianService _service = PengembalianService();

  // Input petugas
  DateTime? tglKembali;
  TimeOfDay? jamKembali;

  bool loading = false;

  // Callback pesan ke UI
  void Function(String, MessageType)? onMessage;

  // Set tanggal kembali
  void setTanggal(DateTime v) {
    tglKembali = v;
    notifyListeners();
  }

  // Set jam kembali
  void setJam(TimeOfDay v) {
    jamKembali = v;
    notifyListeners();
  }

  // =========================
  // Hitung denda keterlambatan
  // =========================
  Map<String, dynamic> hitungDenda(DateTime tenggat, {required DateTime tglTenggat}) {
    if (tglKembali == null) {
      return {'terlambat': false, 'hari': 0, 'denda': 0};
    }

    final diff =
        DateTime(tglKembali!.year, tglKembali!.month, tglKembali!.day)
            .difference(DateTime(tenggat.year, tenggat.month, tenggat.day))
            .inDays;

    if (diff > 0) {
      return {'terlambat': true, 'hari': diff, 'denda': diff * 5000};
    }
    return {'terlambat': false, 'hari': 0, 'denda': 0};
  }

  // =========================
  // Konfirmasi & simpan ke DB
  // =========================
  Future<void> konfirmasi({
    required String idPeminjaman,
    required DateTime tglTenggat,
  }) async {
    // Validasi input
    if (tglKembali == null || jamKembali == null) {
      onMessage?.call("Tanggal & jam wajib diisi", MessageType.warning);
      return;
    }

    final hasil = hitungDenda(tglTenggat, tglTenggat: tglTenggat);

    try {
      loading = true;
      notifyListeners();

      await _service.simpanPengembalian(
        idPeminjaman: idPeminjaman,
        tglKembali: tglKembali!,
        jamKembali:
            "${jamKembali!.hour.toString().padLeft(2, '0')}:${jamKembali!.minute.toString().padLeft(2, '0')}:00",
        terlambatHari: hasil['hari'],
        denda: hasil['denda'], tglKembaliReal: DateTime(
          tglKembali!.year,
          tglKembali!.month,
          tglKembali!.day,
          jamKembali!.hour,
          jamKembali!.minute,
        ),
      );

      onMessage?.call(
        "Pengembalian berhasil disimpan",
        MessageType.success,
      );
    } catch (e) {
      onMessage?.call(e.toString(), MessageType.error);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
