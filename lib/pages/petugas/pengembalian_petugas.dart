import 'package:flutter/material.dart';
import 'form_pengembalian.dart'; // Pastikan nama file ini sesuai

class PengembalianPetugas extends StatefulWidget {
  const PengembalianPetugas({super.key});

  @override
  State<PengembalianPetugas> createState() => _PengembalianPetugasState();
}

class _PengembalianPetugasState extends State<PengembalianPetugas> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // --- HEADER ---
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
                  "Pengembalian",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Kelola data pengembalian alat laboratorium",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // --- SEARCH & FILTER ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
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
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabItem(0, "Semua"),
                      _buildTabItem(1, "Pengembalian"),
                      _buildTabItem(2, "Selesai"),
                      _buildTabItem(3, "Terlambat"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildReturnCard(
                  context,
                  name: "Monica",
                  status: "Pengembalian",
                  statusColor: Colors.orange,
                  buttonText: "Proses Pengembalian",
                  buttonColor: const Color(0xFF00A36C),
                  isClickable: true,
                ),
                _buildReturnCard(
                  context,
                  name: "Andi Saputra",
                  status: "Terlambat",
                  statusColor: Colors.red,
                  buttonText: "Proses Pengembalian",
                  buttonColor: const Color(0xFF00A36C),
                  isClickable: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0061D1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0061D1)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF0061D1),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildReturnCard(
    BuildContext context, {
    required String name,
    required String status,
    required Color statusColor,
    required String buttonText,
    required Color buttonColor,
    required bool isClickable,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.person_outline, color: Color(0xFF0061D1)),
              ),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Tanggal Pinjam", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("20-12-2025 s/d 25-12-2025", style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isClickable ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormPengembalian()),
                );
              } : null,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }
}