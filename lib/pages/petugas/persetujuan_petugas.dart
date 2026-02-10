import 'package:flutter/material.dart';
import '../../controller/persetujuan_controller.dart';

class PersetujuanPetugas extends StatefulWidget {
  const PersetujuanPetugas({super.key});

  @override
  State<PersetujuanPetugas> createState() => _PersetujuanPetugasState();
}

class _PersetujuanPetugasState extends State<PersetujuanPetugas> {
  late final PersetujuanController controller;

  @override
  void initState() {
    super.initState();

    controller = PersetujuanController();

    // Terima pesan dari controller untuk ditampilkan di UI
    controller.onMessage = (msg, type) {
      if (!mounted) return;

      if (type == MessageType.success) {
        _showSuccessDialog(msg);
        return;
      }

      Color color = Colors.green;
      if (type == MessageType.warning) {
        color = Colors.orange;
      } else if (type == MessageType.error) {
        color = Colors.red;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ======================
  // DIALOGS (UI ONLY)
  // ======================
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 100),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(String idPeminjaman) {
    final alasanCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Alasan Penolakan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Mohon isi alasan pengajuan penolakan",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: alasanCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis alasan penolakan disini",
                filled: true,
                fillColor: const Color(0xFFE3F2FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final alasan = alasanCtrl.text;
                      Navigator.pop(context);
                      await controller.tolak(idPeminjaman, alasan);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061D1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Kirim",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).whenComplete(() => alasanCtrl.dispose());
  }

  // ======================
  // UI BUILD
  // ======================
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Column(
            children: [
              // Header Biru
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF0061D1),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Persetujuan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Kelola data persetujuan alat laboratorium",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: controller.loading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.items.isEmpty
                        ? const Center(child: Text("Tidak ada pengajuan menunggu"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: controller.items.length,
                            itemBuilder: (context, i) {
                              final r = controller.items[i];

                              final idPeminjaman = r['id_peminjaman'].toString();
                              final idUser = r['id_user'].toString();

                              final mulai = controller.formatDate(r['tgl_pinjam']);
                              final selesai = controller.formatDate(
                                r['tgl_kembali_rencana'],
                              );
                              final date = "$mulai s/d $selesai";

                              return _buildApprovalCard(
                                idPeminjaman: idPeminjaman,
                                idUser: idUser,
                                date: date,
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApprovalCard({
    required String idPeminjaman,
    required String idUser,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "User: $idUser",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Menunggu",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          const Text(
            "Tanggal Pinjam",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRejectDialog(idPeminjaman),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text("Tolak"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.setujui(idPeminjaman),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Setujui"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF52C41A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
