import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> generateLaporan() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- KOP SURAT (Header Gambar 1) ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("SMK BRANTAS KARANGKATES",
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("Jl. Lolaras No. 14, Karangkates, Kec. Sumberpucung"),
                    pw.Text("Kabupaten Malang, Jawa Timur 65165"),
                    pw.Text("Telepon: (0341) 385055"),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 2), // Garis tebal bawah kop
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // --- JUDUL LAPORAN ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("LAPORAN DATA PEMINJAMAN ALAT",
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Periode: Hari Ini",
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // --- TABEL DATA (Sesuai Gambar 1) ---
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                },
                headers: ['Nama Alat / Barang', 'Dipinjam', 'Kembali'],
                data: [
                  ['Proyektor Epson EB-X400', '4', '2'],
                  ['Flashdisk Sandisk 32GB', '2', '1'],
                  ['Kabel HDMI 5 Meter', '2', '2'],
                  // Anda bisa looping data dari database di sini
                ],
              ),

              pw.SizedBox(height: 50),

              // --- TANDA TANGAN (Opsional, biasanya ada di laporan resmi) ---
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  children: [
                    pw.Text("Malang, ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}"),
                    pw.SizedBox(height: 60),
                    pw.Text("( Petugas Laboratorium )",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}