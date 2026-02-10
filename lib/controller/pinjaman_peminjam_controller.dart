class PinjamanPeminjamController {
  
  // Data dummy yang mensimulasikan database
  final List<Map<String, dynamic>> allData = [
    {"nama": "Monitor Dell", "peminjam": "Monica", "status": "Aktif", "tgl": "20-12-2025 s/d 25-12-2025", "isSelesai": false},
    {"nama": "Proyektor Epson", "peminjam": "Monica", "status": "Pengajuan", "tgl": "21-12-2025 s/d 23-12-2025", "isSelesai": false},
    {"nama": "Kabel HDMI", "peminjam": "Monica", "status": "Pengembalian", "tgl": "19-12-2025 s/d 20-12-2025", "isSelesai": true},
    {"nama": "Laptop HP", "peminjam": "Monica", "status": "Ditolak", "tgl": "18-12-2025 s/d 18-12-2025", "isSelesai": true},
    {"nama": "Keyboard Logi", "peminjam": "Monica", "status": "Aktif", "tgl": "15-12-2025 s/d 20-12-2025", "isSelesai": false},
  ];

  final List<String> statusOptions = ["Semua", "Aktif", "Pengajuan", "Pengembalian", "Ditolak"];

  // Fungsi untuk mendapatkan data yang sudah difilter
  List<Map<String, dynamic>> getFilteredData({
    required bool showAktifTab,
    required String searchQuery,
    required String selectedStatus,
  }) {
    return allData.where((item) {
      // 1. Filter berdasarkan Tab (Aktif vs Selesai)
      bool matchesTab = showAktifTab ? !item['isSelesai'] : item['isSelesai'];
      
      // 2. Filter berdasarkan Pencarian Nama Alat
      bool matchesSearch = item['nama'].toLowerCase().contains(searchQuery.toLowerCase());
      
      // 3. Filter berdasarkan Dropdown Status
      bool matchesStatus = (selectedStatus == "Semua") || (item['status'] == selectedStatus);
          
      return matchesTab && matchesSearch && matchesStatus;
    }).toList();
  }

  // Menghitung jumlah untuk badge di Tab
  int countData(bool isSelesai) {
    return allData.where((item) => item['isSelesai'] == isSelesai).length;
  }
}