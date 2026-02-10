import 'package:flutter/foundation.dart';
import '../services/persetujuan_service.dart';

enum MessageType { success, warning, error }

class PersetujuanController extends ChangeNotifier {
  PersetujuanController({PersetujuanService? service})
      : _service = service ?? PersetujuanService();

  final PersetujuanService _service;

  bool loading = false;
  List<Map<String, dynamic>> items = [];

  void Function(String message, MessageType type)? onMessage;

  Future<void> load() async {
    try {
      _setLoading(true);
      items = await _service.fetchMenunggu();
      notifyListeners();
    } catch (e) {
      onMessage?.call("Gagal memuat data: $e", MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setujui(String idPeminjaman) async {
    try {
      _setLoading(true);
      await _service.setujui(idPeminjaman);
      onMessage?.call("Peminjaman telah disetujui", MessageType.success);
      await load();
    } catch (e) {
      onMessage?.call("Gagal menyetujui: $e", MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> tolak(String idPeminjaman, String alasan) async {
    if (alasan.trim().isEmpty) {
      onMessage?.call("Alasan penolakan wajib diisi", MessageType.warning);
      return;
    }

    try {
      _setLoading(true);
      await _service.tolak(idPeminjaman, alasan);
      onMessage?.call("Penolakan telah dikirim", MessageType.warning);
      await load();
    } catch (e) {
      onMessage?.call("Gagal menolak: $e", MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  String formatDate(dynamic v) {
    if (v == null) return '-';
    try {
      final d = DateTime.parse(v.toString());
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yy = d.year.toString();
      return "$dd-$mm-$yy";
    } catch (_) {
      return v.toString();
    }
  }

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }
}
