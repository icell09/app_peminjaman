import 'package:flutter/material.dart';

class AlatAdmin extends StatefulWidget {
  const AlatAdmin({super.key});

  @override
  State<AlatAdmin> createState() => _AlatAdminState();
}

class _AlatAdminState extends State<AlatAdmin> {
  // --- STATE MANAGEMENT ---
  String _searchQuery = "";
  String _selectedKategori = "Semua";
  bool _isAlatTab = true; // Kontrol untuk efek geser tab

  final List<String> _kategoriList = [
    "Semua",
    "Perangkat Keras",
    "Perangkat Penyimpanan",
    "Perangkat Jaringan",
    "Perangkat Output"
  ];

  // Data Dummy
  final List<Map<String, dynamic>> _allAlat = [
    {'nama': 'Logitech G305', 'stok': 16, 'kategori': 'Perangkat Keras'},
    {'nama': 'SSD Samsung 1TB', 'stok': 5, 'kategori': 'Perangkat Penyimpanan'},
    {'nama': 'Router TP-Link', 'stok': 8, 'kategori': 'Perangkat Jaringan'},
    {'nama': 'Monitor Dell 24"', 'stok': 12, 'kategori': 'Perangkat Output'},
  ];

  @override
  Widget build(BuildContext context) {
    // Logika Filter
    final filteredAlat = _allAlat.where((item) {
      final matchesSearch = item['nama'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesKategori = _selectedKategori == "Semua" || item['kategori'] == _selectedKategori;
      return matchesSearch && matchesKategori;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER RAMPING ---
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
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Alat', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Kelola dan pantau ketersediaan alat laboratorium',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

            // --- 2. SEARCH & FILTER (TAMPILAN TETAP) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Cari alat ...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterManual(),
                ],
              ),
            ),

            // --- 3. SLIDING TAB (EFEK GESER) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Indikator Background yang bergeser
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: _isAlatTab ? Alignment.centerLeft : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0061CD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    // Teks Tab
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isAlatTab = true),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Text(
                                "Alat",
                                style: TextStyle(
                                  color: _isAlatTab ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isAlatTab = false),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Text(
                                "Kategori",
                                style: TextStyle(
                                  color: !_isAlatTab ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- 4. LIST DATA ---
            Expanded(
              child: _isAlatTab 
                ? _buildAlatContent(filteredAlat) 
                : _buildKategoriContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0061CD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildFilterManual() {
    return PopupMenuButton<String>(
      onSelected: (String value) => setState(() => _selectedKategori = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0061CD)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_alt_outlined, color: Color(0xFF0061CD), size: 18),
            const SizedBox(width: 4),
            Text(
              _selectedKategori, 
              style: const TextStyle(color: Color(0xFF0061CD), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0061CD)),
          ],
        ),
      ),
      itemBuilder: (context) => _kategoriList.map((item) => PopupMenuItem(value: item, child: Text(item))).toList(),
    );
  }

  Widget _buildAlatContent(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text("Alat tidak ditemukan"));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0061CD)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(item['kategori'], style: const TextStyle(color: Colors.blue, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKategoriContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _kategoriList.where((k) => k != "Semua").length,
      itemBuilder: (context, index) {
        final kategori = _kategoriList.where((k) => k != "Semua").toList()[index];
        return ListTile(
          leading: const Icon(Icons.folder_outlined, color: Color(0xFF0061CD)),
          title: Text(kategori),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}