import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/user_model.dart';

class PetugasController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =======================================================
  // PERSETUJUAN PEMINJAMAN (PETUGAS)
  // =======================================================

  Future<List<Map<String, dynamic>>> fetchPengajuanMenunggu() async {
    final res = await _supabase
        .from('peminjaman')
        .select('''
        id_peminjaman,
        tgl_pinjam,
        tgl_kembali_rencana,
        status,
        users(nama),
        detail_peminjaman(
          jumlah_pinjam,
          alat(nama_alat)
        )
      ''')
        .eq('status', 'menunggu')
        .order('tgl_pinjam');

    return List<Map<String, dynamic>>.from(res);
  }

  //setujui peminjaman
  Future<void> setujuiPeminjaman(String idPeminjaman) async {
    await _supabase
        .from('peminjaman')
        .update({'status': 'disetujui'})
        .eq('id_peminjaman', idPeminjaman);
  }

  //tolak peminjaman
  Future<void> tolakPeminjaman({
    required String idPeminjaman,
    required String alasan,
  }) async {
    await _supabase
        .from('peminjaman')
        .update({'status': 'ditolak', 'alasan_penolakan': alasan})
        .eq('id_peminjaman', idPeminjaman);
  }

  // =======================================================
  // AUTH & PROFIL PETUGAS
  // =======================================================
  /// Data tambahan (nama, role) diambil dari userMetadata
  UserModel getLoggedInUser() {
    final user = _supabase.auth.currentUser;
    final metadata = user?.userMetadata;

    return UserModel(
      nama: metadata?['nama'] ?? "Nama Tidak Tersedia",
      email: user?.email ?? "Email Tidak Tersedia",
      password: "", // Tidak disimpan untuk keamanan
      status: metadata?['role'] ?? "Petugas",
    );
  }

  /// Logout user dari Supabase
  Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();

      if (context.mounted) {
        // Menghapus semua route agar user tidak bisa kembali ke halaman sebelumnya
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Logout: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // LOGIKA HITUNG DENDA

  /// Menghitung denda keterlambatan pengembalian alat
  /// Return:
  /// - isTerlambat : bool
  /// - selisih     : jumlah hari terlambat
  /// - denda       : total denda (Rp 5.000 / hari)
  Map<String, dynamic> hitungDenda(DateTime tenggat, DateTime? kembali) {
    if (kembali == null) {
      return {"isTerlambat": false, "selisih": 0, "denda": 0};
    }

    // Normalisasi tanggal (tanpa jam)
    DateTime t1 = DateTime(tenggat.year, tenggat.month, tenggat.day);
    DateTime t2 = DateTime(kembali.year, kembali.month, kembali.day);

    if (t2.isAfter(t1)) {
      int selisih = t2.difference(t1).inDays;
      return {"isTerlambat": true, "selisih": selisih, "denda": selisih * 5000};
    }

    return {"isTerlambat": false, "selisih": 0, "denda": 0};
  }

  // =======================================================
  // LAPORAN PETUGAS (PDF)
  // =======================================================

  /// Fungsi ini hanya MEMBUAT PDF (belum print)
  /// Proses print / preview dilakukan di UI menggunakan package `printing`
  Future<Uint8List> generateLaporanPetugasPdf({
    required String namaPetugas,
    required String periode,
    required int totalPeminjaman,
    required int selesai,
    required int terlambat,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              // =======================
              // HEADER
              // =======================
              pw.Text(
                "LAPORAN PETUGAS",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),

              pw.Text("Nama Petugas : $namaPetugas"),
              pw.Text("Periode : $periode"),
              pw.SizedBox(height: 20),

              // =======================
              // RINGKASAN
              // =======================
              pw.Text(
                "Ringkasan",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  _pdfRow("Total Peminjaman", totalPeminjaman.toString()),
                  _pdfRow("Pengembalian Selesai", selesai.toString()),
                  _pdfRow("Terlambat", terlambat.toString()),
                ],
              ),

              pw.SizedBox(height: 40),

              // =======================
              // TANDA TANGAN
              // =======================
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Petugas,"),
                    pw.SizedBox(height: 40),
                    pw.Text(namaPetugas),
                  ],
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  // =======================================================
  // LAPORAN RINGKASAN PEMINJAMAN (HARIAN / BULANAN)
  // =======================================================

  /// Mengambil ringkasan peminjaman alat dari Supabase
  /// Berdasarkan rentang tanggal
  ///
  /// Return:
  /// - total   : jumlah semua peminjaman
  /// - aktif   : status masih dipinjam
  /// - kembali : status sudah dikembalikan
  Future<Map<String, int>> getRingkasanPeminjaman({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _supabase
        .from('peminjaman')
        .select('status')
        .gte('tanggal_pinjam', start.toIso8601String())
        .lte('tanggal_pinjam', end.toIso8601String());

    int aktif = 0;
    int kembali = 0;

    for (final data in result) {
      if (data['status'] == 'aktif') aktif++;
      if (data['status'] == 'kembali') kembali++;
    }

    return {"total": aktif + kembali, "aktif": aktif, "kembali": kembali};
  }

  /// =======================================================
  /// GENERATE PDF LAPORAN RINGKASAN PEMINJAMAN
  /// (Per Hari / Per Bulan)
  /// =======================================================
  ///
  /// NOTE:
  /// - Fungsi ini hanya MEMBUAT PDF
  /// - Print / Preview dilakukan di UI
  Future<Uint8List> generatePdfRingkasanPeminjaman({
    required String jenisLaporan, // "Harian" / "Bulanan"
    required DateTime start,
    required DateTime end,
  }) async {
    final ringkasan = await getRingkasanPeminjaman(start: start, end: end);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ======================
              // JUDUL
              // ======================
              pw.Text(
                'LAPORAN RINGKASAN PEMINJAMAN ALAT',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),

              pw.Text('Jenis Laporan : $jenisLaporan'),
              pw.Text('Periode : ${start.toLocal()} s/d ${end.toLocal()}'),

              pw.SizedBox(height: 20),

              // ======================
              // ISI RINGKASAN
              // ======================
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  _pdfRow('Total Peminjaman', ringkasan['total'].toString()),
                  _pdfRow('Status Aktif', ringkasan['aktif'].toString()),
                  _pdfRow('Status Kembali', ringkasan['kembali'].toString()),
                ],
              ),

              pw.Spacer(),

              // ======================
              // FOOTER
              // ======================
              pw.Text(
                'Dicetak pada: ${DateTime.now()}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // =======================================================
  // HELPER PDF
  // =======================================================

  /// Helper untuk membuat baris tabel PDF
  pw.TableRow _pdfRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }
}
