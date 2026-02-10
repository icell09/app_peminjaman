import 'package:flutter/material.dart';
import '../../services/petugas_service.dart';
import 'pengembalian_petugas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormPengembalian extends StatefulWidget {
  const FormPengembalian({super.key});

  @override
  State<FormPengembalian> createState() => _FormPengembalianState();
}

class _FormPengembalianState extends State<FormPengembalian> {
  // Gunakan PetugasController sesuai file service kamu
  final _service = PetugasController();

  // Data Dummy (Nanti bisa diambil dari constructor/API)
  final String tglPinjam = "20-12-2025";
  final DateTime tglTenggat = DateTime(2025, 12, 25);

  DateTime? tglKembali;
  TimeOfDay? jamKembali;

  // --- LOGIKA HITUNG DENDA (PERBAIKAN UTAMA) ---
  Map<String, dynamic> _hitungDenda(DateTime tenggat, DateTime? kembali) {
    if (kembali == null) {
      return {'isTerlambat': false, 'selisih': 0, 'denda': 0};
    }

    // Hanya menghitung tanggal (tanpa jam) untuk selisih hari
    final dateTenggat = DateTime(tenggat.year, tenggat.month, tenggat.day);
    final dateKembali = DateTime(kembali.year, kembali.month, kembali.day);

    final selisihHari = dateKembali.difference(dateTenggat).inDays;

    if (selisihHari > 0) {
      return {
        'isTerlambat': true,
        'selisih': selisihHari,
        'denda': selisihHari * 5000, // Misal denda 5rb per hari
      };
    } else {
      return {'isTerlambat': false, 'selisih': 0, 'denda': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jalankan fungsi hitung denda
    final Map<String, dynamic> hasil = _hitungDenda(tglTenggat, tglKembali);
    bool sudahInputLengkap = tglKembali != null && jamKembali != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemCard("Mouse Logitech G305", "2"),
                  const SizedBox(height: 25),

                  _buildLabel("Tanggal Pinjam :"),
                  _buildRowInfo(tglPinjam, "12:54"),
                  const SizedBox(height: 15),

                  _buildLabel("Tanggal Tenggat :"),
                  _buildRowInfo("25-12-2025", "14:00"),
                  const SizedBox(height: 15),

                  _buildLabel("Tanggal Pengembalian (Input Petugas) :"),
                  _buildInputTanggalWaktu(),

                  // Muncul otomatis jika terlambat & input lengkap
                  if (sudahInputLengkap && hasil['isTerlambat']) ...[
                    const SizedBox(height: 25),
                    _buildLateCard(hasil['selisih'], hasil['denda']),
                  ],

                  const SizedBox(height: 40),

                  _buildButtonKonfirmasi(sudahInputLengkap, hasil),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN UI ---

  Widget _buildLateCard(int hari, int denda) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 10),
              const Text(
                "Terlambat!",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Terlambat $hari hari dari batas waktu.",
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Denda",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp $denda",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonKonfirmasi(bool isEnabled, Map hasil) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEnabled ? const Color(0xFF0061D1) : Colors.grey.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed:
          isEnabled
              ? () {
                if (hasil['isTerlambat']) {
                  _showLateSnackBar();
                }
                _showSuccessDialog();
              }
              : null,
      child: const Text(
        "Konfirmasi Pengembalian",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );

  void _showLateSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Denda keterlambatan telah dicatat"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 15),
                Text(
                  "Berhasil!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Data pengembalian telah disimpan."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c); // Tutup Dialog
                  Navigator.pop(context); // Kembali ke list
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    width: double.infinity,
    height: 110,
    decoration: const BoxDecoration(
      color: Color(0xFF0061D1),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 40, left: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Detail Pengembalian",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildInputTanggalWaktu() => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () async {
            DateTime? p = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            );
            if (p != null) setState(() => tglKembali = p);
          },
          child: _buildBoxStyle(
            "Tanggal",
            tglKembali == null
                ? "Isi Tanggal"
                : "${tglKembali!.day}-${tglKembali!.month}-${tglKembali!.year}",
            Icons.calendar_month,
            isFilled: tglKembali != null,
          ),
        ),
      ),
      const SizedBox(width: 15),
      Expanded(
        child: InkWell(
          onTap: () async {
            TimeOfDay? t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (t != null) setState(() => jamKembali = t);
          },
          child: _buildBoxStyle(
            "Waktu",
            jamKembali == null ? "Isi Waktu" : jamKembali!.format(context),
            Icons.access_time,
            isFilled: jamKembali != null,
          ),
        ),
      ),
    ],
  );

  Widget _buildBoxStyle(
    String label,
    String val,
    IconData icon, {
    bool isFilled = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: isFilled ? null : Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                val,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isFilled ? Colors.black : Colors.blueGrey,
                  fontWeight: isFilled ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(icon, size: 16, color: Colors.blue),
          ],
        ),
      ),
    ],
  );

  Widget _buildItemCard(String n, String q) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFF1F4F8),
          child: Icon(Icons.inventory_2, color: Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(n, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Text(
          "Qty: $q",
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _buildLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
  Widget _buildRowInfo(String d, String t) => Row(
    children: [
      Expanded(
        child: _buildBoxStyle(
          "Tanggal",
          d,
          Icons.calendar_today,
          isFilled: true,
        ),
      ),
      const SizedBox(width: 15),
      Expanded(
        child: _buildBoxStyle("Waktu", t, Icons.access_time, isFilled: true),
      ),
    ],
  );
}
