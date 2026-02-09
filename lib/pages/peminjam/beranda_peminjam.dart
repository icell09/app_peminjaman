import 'package:flutter/material.dart';
import '../../services/alat_service.dart';
import 'form_pengajuan.dart';

class BerandaPeminjam extends StatefulWidget {
  const BerandaPeminjam({super.key});

  @override
  State<BerandaPeminjam> createState() => _BerandaPeminjamState();
}

class _BerandaPeminjamState extends State<BerandaPeminjam> {
  final AlatSupabaseService _service = AlatSupabaseService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _alat = [];
  List<Map<String, dynamic>> _filteredAlat = [];
  List<Map<String, dynamic>> _kategoriList = [];

  bool _loading = true;
  int? _selectedKategoriId;

  // Keranjang untuk menyimpan alat yang dipilih
  final _keranjang = _Keranjang();

  @override
  void initState() {
    super.initState();
    _loadAlat();
    _loadKategori();
  }

  Future<void> _loadAlat() async {
    final data = await _service.fetchAlat();
    setState(() {
      _alat = data;
      _filteredAlat = data;
      _loading = false;
    });
  }

  Future<void> _loadKategori() async {
    final data = await _service.fetchKategori();
    setState(() {
      _kategoriList = data;
    });
  }

  void _applyFilter() {
    final keyword = _searchCtrl.text.toLowerCase();

    setState(() {
      _filteredAlat =
          _alat.where((a) {
            final nama = a['nama_alat'].toString().toLowerCase();
            final matchSearch = nama.contains(keyword);
            final matchKategori =
                _selectedKategoriId == null ||
                a['id_kategori'] == _selectedKategoriId;

            return matchSearch && matchKategori;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _header(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _welcomeCard(),
                          const SizedBox(height: 16),
                          _searchField(),
                          const SizedBox(height: 12),
                          _kategoriChips(),
                          const SizedBox(height: 16),
                          ..._filteredAlat.map(_alatCard),
                        ],
                      ),
                    ),
                  ],
                ),
      ),

      //button lihat keranjang
      bottomNavigationBar:
          _keranjang.total == 0
              ? null
              : Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                FormPeminjaman(alatDipilih: _keranjang.items),
                      ),
                    );
                  },
                  child: Text(
                    'Lihat (${_keranjang.total})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
    );
  }

  //UI
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0061CD),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Beranda Peminjam',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Selamat Datang \n Peminjam👋',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Image.asset('assets/images/admin.png', width: 80),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (_) => _applyFilter(),
      decoration: InputDecoration(
        hintText: 'Cari nama alat',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _kategoriChips() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: const Text('Semua'),
            selected: _selectedKategoriId == null,
            onSelected: (_) {
              _selectedKategoriId = null;
              _applyFilter();
            },
          ),
          ..._kategoriList.map((k) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(k['nama_kategori']),
                selected: _selectedKategoriId == k['id_kategori'],
                onSelected: (_) {
                  _selectedKategoriId = k['id_kategori'];
                  _applyFilter();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _alatCard(Map<String, dynamic> a) {
    final tersedia = a['stok'] > 0;
    return GestureDetector(
      onTap:
          tersedia
              ? () {
                setState(() {
                  _keranjang.add(a);
                });
              }
              : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                a['gambar'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['nama_alat'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tersedia ? 'Tersedia' : 'Habis',
                    style: TextStyle(
                      color: tersedia ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
    ],
  );
}

class _Keranjang {
  List<Map<String, dynamic>> items = [];

  int get total => items.fold(0, (sum, item) {
    final qty = item['qty'] ?? 1;
    return sum + (qty is int ? qty : int.parse(qty.toString()));
  });

  void add(Map<String, dynamic> alat) {
    final index = items.indexWhere(
      (item) => item['id_alat'] == alat['id_alat'],
    );
    if (index >= 0) {
      items[index]['qty'] = (items[index]['qty'] ?? 1) + 1; // tambah qty
    } else {
      items.add({...alat, 'qty': 1});
    }
  }
}
