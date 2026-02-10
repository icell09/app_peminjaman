import 'package:flutter/material.dart';
import '../../controller/pinjaman_peminjam_controller.dart';

class PinjamanPeminjam extends StatefulWidget {
  const PinjamanPeminjam({super.key});

  @override
  State<PinjamanPeminjam> createState() => _PinjamanPeminjamState();
}

class _PinjamanPeminjamState extends State<PinjamanPeminjam> {
  final PinjamanPeminjamController _controller = PinjamanPeminjamController();
  
  // State variables
  bool _showAktifTab = true;
  String _searchQuery = "";
  String _selectedStatus = "Semua";

  @override
  Widget build(BuildContext context) {
    // Memproses data berdasarkan state saat ini
    final List<Map<String, dynamic>> displayData = _controller.getFilteredData(
      showAktifTab: _showAktifTab,
      searchQuery: _searchQuery,
      selectedStatus: _selectedStatus,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 15),
            _buildSearchAndFilter(),
            _buildTabSwitcher(),
            
            // List Area
            Expanded(
              child: displayData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: displayData.length,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (context, index) => _buildLoanCard(displayData[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0061C1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pinjaman Saya', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Kelola pinjaman alat dengan mudah', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari alat...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0061C1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0061C1)),
                  items: _controller.statusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0061C1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tabItem("Aktif (${_controller.countData(false)})", _showAktifTab, () => setState(() => _showAktifTab = true)),
          _tabItem("Selesai (${_controller.countData(true)})", !_showAktifTab, () => setState(() => _showAktifTab = false)),
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0061C1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : const Color(0xFF0061C1))),
        ),
      ),
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> data) {
    Color themeColor = _getStatusColor(data['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFF0061C1), child: Icon(Icons.inventory, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Text(data['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(data['status'], style: TextStyle(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 25),
          const Text('Jangka Waktu Pinjam', style: TextStyle(color: Colors.grey, fontSize: 11)),
          Text(data['tgl'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif': return Colors.green;
      case 'Pengajuan': return Colors.blue;
      case 'Pengembalian': return Colors.orange;
      case 'Ditolak': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.grey)));
  }
}