import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../services/pdf_service.dart';


class PreviewLaporanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- HEADER FLOATING CARD (Sama dengan halaman utama) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0061D1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
        // 1. Ikon di sebelah kiri
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 4),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PDF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Periksa data sebelum dicetak",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- TAMPILAN DOKUMEN (Gambar 1) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: PdfPreview(
                    build: (format) => PdfService.generateLaporan(),
                    useActions: false, // Menghilangkan toolbar bawaan
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    maxPageWidth: 600,
                  ),
                ),
              ),
            ),
          ),

          // --- TOMBOL CETAK DI BAGIAN BAWAH ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final pdfData = await PdfService.generateLaporan();
                  await Printing.layoutPdf(
                    onLayout: (format) => pdfData,
                    name: 'Laporan_Peminjaman_SMK.pdf',
                  );
                },
                icon: const Icon(Icons.print_rounded, color: Colors.white),
                label: const Text(
                  "CETAK LAPORAN SEKARANG",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700], // Hijau untuk aksi sukses/cetak
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}