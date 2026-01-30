import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Lato'),
      home: const BerandaAdmin(),
    );
  }
}

class BerandaAdmin extends StatelessWidget {
  const BerandaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  _buildSummaryGrid(),
                  const SizedBox(height: 24),
                  const Text(
                    "Grafik Alat Yang Sering Dipinjam",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildChartCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Komponen ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0061D1),
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
            children: const [
              Text(
                "Beranda",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Kelola data peminjaman sekolah dengan mudah",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.notifications, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Selamat Datang,", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text("Admin 👋", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Placeholder untuk Ilustrasi (Gunakan Image.asset jika ada gambarnya)
          Image.asset('assets/images/admin.png', width: 120, height: 120),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("4", "Total Alat", Colors.blue[100]!, Colors.blue),
        _statCard("4", "Alat Rusak", Colors.red[100]!, Colors.red),
        _statCard("4", "Alat Tersedia", Colors.green[100]!, Colors.green),
        _statCard("4", "Sedang Dipinjam", Colors.orange[100]!, Colors.orange),
      ],
    );
  }

  Widget _statCard(String value, String label, Color bgColor, Color textColor) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 300, // Tinggi area grafik ditambah agar lega
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          // FIX 1: maxY harus lebih tinggi dari data tertinggi (220)
          maxY: 250, 
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            // FIX 2: Perbaikan Label Bawah (Sumbu X)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45, // Ruang untuk teks agar tidak terpotong
                getTitlesWidget: (value, meta) {
                  const titles = ['Mouse', 'Kybord', 'Proyekt', 'Fldisk', 'Router', 'Kabel', 'Laptop'];
                  // Menggunakan SideTitleWidget agar posisi teks presisi
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10, // Jarak teks ke batang
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  );
                },
              ),
            ),
            // FIX 3: Perbaikan Angka Samping (Sumbu Y)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Ruang agar angka puluhan tidak tumpang tindih
                interval: 50,    // Memunculkan angka tiap kelipatan 50 (0, 50, 100, dst)
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 220),
            _makeGroupData(1, 150),
            _makeGroupData(2, 210),
            _makeGroupData(3, 120),
            _makeGroupData(4, 60),
            _makeGroupData(5, 150),
            _makeGroupData(6, 190),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu untuk membuat batang grafik yang rapi
  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF0061D1),
          width: 18, // Lebar batang
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}