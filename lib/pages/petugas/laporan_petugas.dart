import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../services/petugas_service.dart';
import 'package:pdf/widgets.dart' as pw;

class LaporanPetugas extends StatefulWidget {
  const LaporanPetugas({super.key});

  @override
  State<LaporanPetugas> createState() => _LaporanPetugasState();
}

class _LaporanPetugasState extends State<LaporanPetugas> {
  final PetugasController _controller = PetugasController();

  String _jenisLaporan = 'Harian';
  DateTime _selectedDate = DateTime.now();

  // =========================
  // AMBIL PERIODE
  // =========================
  DateTime get _startDate {
    if (_jenisLaporan == 'Harian') {
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
    }
    return DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  DateTime get _endDate {
    if (_jenisLaporan == 'Harian') {
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        23,
        59,
        59,
      );
    }
    return DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
  }

  // =========================
  // CETAK / PREVIEW PDF
  // =========================
  Future<void> _cetakPdf() async {
    try {
      final pdfData = await _controller.generateLaporanPetugasPdf(
        namaPetugas: 'Tes',
        periode: 'Harian',
        totalPeminjaman: 5,
        selesai: 3,
        terlambat: 1,
      );

      await Printing.layoutPdf(
        name: 'Laporan_Petugas.pdf',
        onLayout: (format) async => pdfData,
      );
    } catch (e) {
      debugPrint('CETAK ERROR: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal cetak PDF')));
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Petugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // PILIH JENIS LAPORAN
            // =========================
            const Text(
              'Jenis Laporan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _jenisLaporan,
              items: const [
                DropdownMenuItem(value: 'Harian', child: Text('Harian')),
                DropdownMenuItem(value: 'Bulanan', child: Text('Bulanan')),
              ],
              onChanged: (value) {
                setState(() {
                  _jenisLaporan = value!;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            // =========================
            // PILIH TANGGAL
            // =========================
            const Text(
              'Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                ),
              ),
            ),

            const Spacer(),

            // =========================
            // BUTTON CETAK
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Cetak PDF'),
                onPressed: _cetakPdf,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
