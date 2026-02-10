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

      // ✅ FIX OVERFLOW: dibuat scrollable
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0061CD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Beranda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola data peminjaman sekolah dengan mudah',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              //KONTEN
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),

                    // ✅ BONUS: agar aman di HP kecil (bisa geser kiri-kanan)
                    _buildSummaryGrid(),
                    const SizedBox(height: 24),

                    const Text(
                      "Grafik Alat Yang Sering Dipinjam",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChartCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Komponen ---

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Selamat Datang,",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Admin 👋",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Pastikan asset ini ada di pubspec.yaml
          Image.asset('assets/images/admin.png', width: 120, height: 120),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _statCard("4", "Total Alat", Colors.blue[100]!, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "4",
            "Alat Tersedia",
            Colors.green[100]!,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "4",
            "Sedang Dipinjam",
            Colors.orange[100]!,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: 250,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  const titles = [
                    'Mouse',
                    'Kybord',
                    'Proyektor',
                    'Flashdisk',
                    'Router',
                  ];
                  if (value.toInt() < 0 || value.toInt() >= titles.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine:
                (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 220),
            _makeGroupData(1, 150),
            _makeGroupData(2, 210),
            _makeGroupData(3, 120),
            _makeGroupData(4, 60),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF0061D1),
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
