import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersetujuanPetugas extends StatefulWidget {
  const PersetujuanPetugas({super.key});

  @override
  State<PersetujuanPetugas> createState() => _PersetujuanPetugasState();
}

class _PersetujuanPetugasState extends State<PersetujuanPetugas> {
  // Define your controller here
  // late YourControllerType _controller;

  @override
  void initState() {
    super.initState();
    // Initialize your controller here
    // _controller = YourControllerType();
  }

  // Fungsi untuk menampilkan Pop-up Sukses (seperti gambar 2)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Peminjaman telah disetujui",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk menampilkan Pop-up Penolakan (seperti gambar 3)
  void _showRejectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => Padding(
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
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.orange,
                              content: Text("Penolakan telah dikirim"),
                            ),
                          );
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari nama / alat",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List Pengajuan
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildApprovalCard(
                  "Monica",
                  "Mouse Logitech G305",
                  "2",
                  "20-12-2025 s/d 25-12-2025",
                ),
                _buildApprovalCard(
                  "Monica",
                  "Mouse Logitech G305",
                  "1",
                  "21-12-2025 s/d 23-12-2025",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(String name, String item, String qty, String date) {
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
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mouse, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  qty,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
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
                  onPressed: _showRejectDialog,
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
                  onPressed: _showSuccessDialog,
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
