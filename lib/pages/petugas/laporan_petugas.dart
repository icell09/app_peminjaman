import 'package:flutter/material.dart';
import 'laporan_petugas_preview.dart'; // Pastikan file preview sudah dibuat

class LaporanPetugas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Biru Melengkung (Sesuai Gambar 2)
          Container(
            padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Color(0xFF0056C1), // Warna biru sesuai gambar
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Laporan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Laporan data peminjaman alat laboratorium",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Icon(Icons.notifications, color: Colors.white, size: 28),
              ],
            ),
          ),
          

          // 2. Tombol Filter & Download
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text("Hari ini", style: TextStyle(color: Color(0xFF0056C1))),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF0056C1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigasi ke Preview PDF (Gambar 1)
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PreviewLaporanPage()),
                          );
                        },
                        child: Text("Download PDF", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0056C1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Statistik Angka
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn("2", "Dipinjam"),
                    _buildStatColumn("2", "Kembali"),
                  ],
                ),
              ],
            ),
          ),

          // 3. Daftar Laporan (Card Monica)
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildLaporanCard(
                  nama: "Monica",
                  tanggal: "20-12-2025 s/d 25-12-2025",
                  items: [
                    {"alat": "Proyektor", "qty": "2 unit"},
                  ],
                ),
                _buildLaporanCard(
                  nama: "Monica",
                  tanggal: "20-12-2025 s/d 25-12-2025",
                  items: [
                    {"alat": "Proyektor", "qty": "2 unit"},
                    {"alat": "Flashdisk", "qty": "1 unit"},
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildLaporanCard({required String nama, required String tanggal, required List<Map<String, String>> items}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.person, color: Color(0xFF0056C1), size: 30),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(tanggal, style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Divider(height: 25, thickness: 1),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['alat']!, style: TextStyle(fontSize: 15, color: Colors.black87)),
                Text(item['qty']!, style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  }