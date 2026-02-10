import 'package:flutter/material.dart';
import '../../controller/pengembalian_controller.dart';
import '../../core/messege_type.dart';
import 'form_pengembalian.dart';

class PengembalianPetugas extends StatefulWidget {
  const PengembalianPetugas({super.key});

  @override
  State<PengembalianPetugas> createState() => _PengembalianPetugasState();
}

class _PengembalianPetugasState extends State<PengembalianPetugas> {
  late final PengembalianController controller;
  final TextEditingController _searchCtrl = TextEditingController();

  // Dropdown filter UI (sesuai screenshot)
  String _filter = "Semua";

  @override
  void initState() {
    super.initState();

    controller = PengembalianController();

    controller.onMessage = (msg, type) {
      if (!mounted) return;

      Color color = Colors.green;

      if (type == MessageType.warning) {
        color = Colors.orange;
      } else if (type == MessageType.error) {
        color = Colors.red;
      }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
};

    controller.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    controller.dispose();
    super.dispose();
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Ambil list dari controller
        var list = controller.filtered;

        // Terapkan filter dropdown (UI layer, biar simpel)
        list = _applyDropdownFilter(list);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                // ===== Header biru (sesuai screenshot) =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pengembalian",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Kelola data pengembalian alat laboratorium",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Search + Dropdown (sesuai screenshot) =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: controller.setKeyword,
                            decoration: const InputDecoration(
                              hintText: "Cari nama ",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filter,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: const [
                              DropdownMenuItem(value: "Semua", child: Text("Semua")),
                              DropdownMenuItem(
                                  value: "Pengembalian", child: Text("Pengembalian")),
                              DropdownMenuItem(value: "Selesai", child: Text("Selesai")),
                              DropdownMenuItem(
                                  value: "Terlambat", child: Text("Terlambat")),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _filter = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Body =====
                Expanded(
                  child: controller.loading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  "Error: ${controller.error}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : list.isEmpty
                              ? const Center(child: Text("Tidak ada data"))
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                                  itemCount: list.length,
                                  itemBuilder: (context, i) {
                                    final r = list[i];

                                    final idPeminjaman = r['id_peminjaman'].toString();
                                    final idUser = r['id_user'].toString();

                                    // status dari DB (normalisasi lower)
                                    final statusLower =
                                        (r['status'] ?? '').toString().toLowerCase();

                                    // terlambat dihitung dari tenggat
                                    final terlambat = controller.isTerlambat(r);

                                    // badge label & color
                                    final badge = _badgeFromStatus(
                                      statusLower: statusLower,
                                      terlambat: terlambat,
                                    );

                                    // tombol: disable jika selesai
                                    final isClickable = statusLower != 'selesai';

                                    return _ReturnCard(
                                      nama: "User: $idUser", // nanti bisa diganti nama user
                                      tanggal: controller.rangeTanggal(r),
                                      badgeText: badge.text,
                                      badgeColor: badge.color,
                                      buttonEnabled: isClickable,
                                      buttonText: isClickable
                                          ? "Proses Pengembalian"
                                          : "Pengembalian Selesai",
                                      onPressed: () async {
                                        // jika sudah selesai, jangan apa2
                                        if (!isClickable) return;

                                        // optional: ubah status jadi dikembalikan
                                        await controller.mulaiProses(idPeminjaman);

                                        final tglTenggat = DateTime.parse(
                                          r['tgl_kembali_rencana'].toString(),
                                        ).toLocal();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FormPengembalian(
                                              idPeminjaman: idPeminjaman,
                                              tglPinjamText: controller.formatDate(
                                                r['tgl_pinjam'],
                                              ),
                                              tglTenggat: tglTenggat,
                                              namaItem: r['nama_item'] ?? 'Alat Laboratorium',
                                              qty: r['qty'] ?? 1,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================
  // Filter dropdown (UI)
  // ======================
  List<Map<String, dynamic>> _applyDropdownFilter(List<Map<String, dynamic>> list) {
    if (_filter == "Semua") return list;

    return list.where((r) {
      final s = (r['status'] ?? '').toString().toLowerCase();
      final terlambat = controller.isTerlambat(r);

      if (_filter == "Selesai") return s == 'selesai';
      if (_filter == "Pengembalian") return s == 'dikembalikan';
      if (_filter == "Terlambat") return terlambat;

      return true;
    }).toList();
  }

  // ======================
  // Badge helper
  // ======================
  _Badge _badgeFromStatus({required String statusLower, required bool terlambat}) {
    if (terlambat && statusLower != 'selesai') {
      return const _Badge("Terlambat", Colors.red);
    }
    if (statusLower == 'selesai') {
      return const _Badge("Selesai", Colors.blue);
    }
    if (statusLower == 'dikembalikan') {
      return const _Badge("Pengembalian", Colors.orange);
    }
    if (statusLower == 'dipinjam') {
      return const _Badge("Dipinjam", Colors.green);
    }
    return const _Badge("Status", Colors.grey);
  }
}

// ======================
// Badge model kecil
// ======================
class _Badge {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);
}

// ======================
// Card 
// ======================
class _ReturnCard extends StatelessWidget {
  final String nama;
  final String tanggal;
  final String badgeText;
  final Color badgeColor;
  final bool buttonEnabled;
  final String buttonText;
  final VoidCallback onPressed;

  const _ReturnCard({
    required this.nama,
    required this.tanggal,
    required this.badgeText,
    required this.badgeColor,
    required this.buttonEnabled,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // avatar besar (mirip screenshot)
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: const Color(0xFF0061D1), width: 3),
                ),
                child: const Icon(Icons.person, color: Color(0xFF0061D1), size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nama,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withOpacity(0.6)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300, height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Tanggal Pinjam",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(tanggal, style: const TextStyle(fontSize: 12)),
          ),
          Divider(color: Colors.grey.shade300, height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: buttonEnabled ? onPressed : null,
              icon: const Icon(Icons.check_circle, size: 18),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonEnabled ? const Color(0xFF00A36C) : Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
