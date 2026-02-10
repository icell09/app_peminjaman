import 'package:flutter/material.dart';
import '../../controller/form_pengembalian_controller.dart';

class FormPengembalian extends StatefulWidget {
  final String idPeminjaman;
  final DateTime tglTenggat;
  final String tglPinjamText; // misal: "20-12-2025 12:54"
  final String namaItem;      // misal: "Mouse Logitech G305"
  final int qty;              // misal: 2

  const FormPengembalian({
    super.key,
    required this.idPeminjaman,
    required this.tglTenggat,
    required this.tglPinjamText,
    required this.namaItem,
    required this.qty,
  });

  @override
  State<FormPengembalian> createState() => _FormPengembalianState();
}

class _FormPengembalianState extends State<FormPengembalian> {
  final controller = FormPengembalianController();

  DateTime? selectedTanggalKembali;
  TimeOfDay? selectedJamKembali;

  @override
  void initState() {
    super.initState();

    controller.onMessage = (msg, type) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      if (type == MessageType.success) {
        Navigator.pop(context);
      }
    };

    // Optional: set default ke sekarang
    selectedTanggalKembali = DateTime.now();
    selectedJamKembali = TimeOfDay.now();
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return "-";
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final hasil = controller.hitungDenda(widget.tglTenggat, tglTenggat: widget.tglTenggat);
    final bool terlambat = hasil['terlambat'] == true;
    final int denda = hasil['denda'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pengembalian"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Info Peminjaman
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.namaItem,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("×${widget.qty}"),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow("Tanggal Pinjam", widget.tglPinjamText),
                    const SizedBox(height: 8),
                    _buildInfoRow("Tanggal Tenggat", 
                      "${widget.tglTenggat.day.toString().padLeft(2, '0')}-${widget.tglTenggat.month.toString().padLeft(2, '0')}-${widget.tglTenggat.year} 14:00"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pilih tanggal & jam pengembalian
            const Text("Tanggal Pengembalian", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedTanggalKembali ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => selectedTanggalKembali = date);
                  controller.setTanggal(date);
                }
              },
              child: _buildDateTimeTile(
                icon: Icons.calendar_today,
                title: selectedTanggalKembali == null 
                    ? "Pilih tanggal" 
                    : "${selectedTanggalKembali!.day.toString().padLeft(2, '0')}-${selectedTanggalKembali!.month.toString().padLeft(2, '0')}-${selectedTanggalKembali!.year}",
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedJamKembali ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => selectedJamKembali = time);
                  controller.setJam(time);
                }
              },
              child: _buildDateTimeTile(
                icon: Icons.access_time,
                title: selectedJamKembali == null 
                    ? "Pilih jam" 
                    : "${selectedJamKembali!.hour.toString().padLeft(2, '0')}:${selectedJamKembali!.minute.toString().padLeft(2, '0')}",
              ),
            ),

            const SizedBox(height: 24),

            // Box Denda Keterlambatan
            if (terlambat)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          "Pengembalian Terlambat",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Terlambat ${hasil['hari']} hari dari estimasi",
                      style: TextStyle(color: Colors.red[800]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Denda Keterlambatan",
                      style: TextStyle(color: Colors.red[800]),
                    ),
                    Text(
                      "Rp ${denda.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  controller.konfirmasi(
                    idPeminjaman: widget.idPeminjaman,
                    tglTenggat: widget.tglTenggat,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Konfirmasi Pengembalian",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDateTimeTile({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}