import 'package:flutter/material.dart';
import '../../services/alat_service.dart';
import 'form_peminjaman.dart';

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

  final _keranjang = _Keranjang();

  static const _primary = Color(0xFF0061CD);
  static const _bg = Color(0xFFF6F8FB);

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
    setState(() => _kategoriList = data);
  }

  void _applyFilter() {
    final keyword = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredAlat = _alat.where((a) {
        final nama = a['nama_alat'].toString().toLowerCase();
        final matchSearch = nama.contains(keyword);
        final matchKategori =
            _selectedKategoriId == null ||
            a['id_kategori'] == _selectedKategoriId;
        return matchSearch && matchKategori;
      }).toList();
    });
  }

  Future<void> _openForm() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPeminjaman(alatDipilih: _keranjang.items),
      ),
    );

    if (result == null) return;

    final items = (result['items'] as List<Map<String, dynamic>>?) ?? [];
    final submitted = (result['submitted'] as bool?) ?? false;

    setState(() {
      if (submitted) {
        _keranjang.clear();
      } else {
        _keranjang.setItems(items);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Beranda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Kelola dan pinjam alat sekolah dengan mudah',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    children: [
                      _welcomeCard(),
                      const SizedBox(height: 10),
                      _searchField(),
                      const SizedBox(height: 10),
                      _kategoriChips(),
                      const SizedBox(height: 10),
                      ..._filteredAlat.map(_alatRow),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _keranjang.total == 0
          ? null
          : SizedBox(
              width: MediaQuery.of(context).size.width - 28,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _openForm,
                child: Text(
                  'Lihat (${_keranjang.total})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }

  // ui
  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Selamat Datang,\nPeminjam 👋',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ),
          Image.asset(
            'assets/images/admin.png',
            width: 110,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black45, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _applyFilter(),
              decoration: const InputDecoration(
                hintText: 'Cari nama alat',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kategoriChips() {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip('Semua', _selectedKategoriId == null, () {
            setState(() => _selectedKategoriId = null);
            _applyFilter();
          }),
          const SizedBox(width: 8),
          ..._kategoriList.map((k) {
            final selected = _selectedKategoriId == k['id_kategori'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(
                k['nama_kategori'],
                selected,
                () {
                  setState(() => _selectedKategoriId = k['id_kategori']);
                  _applyFilter();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _primary,
          ),
        ),
      ),
    );
  }

  Widget _alatRow(Map<String, dynamic> a) {
    final tersedia = (a['stok'] ?? 0) > 0;

    return InkWell(
      onTap: tersedia ? () => setState(() => _keranjang.add(a)) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.network(a['gambar'], fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['nama_alat'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: tersedia
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tersedia ? 'Tersedia' : 'Kosong',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: tersedia ? Colors.green : Colors.red,
                      ),
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
}

// Keranjang 
class _Keranjang {
  List<Map<String, dynamic>> items = [];

  int get total => items.fold<int>(0, (sum, item) {
        final qty = item['qty'] ?? 1;
        final q = (qty is int) ? qty : int.parse(qty.toString());
        return sum + q;
      });

  void add(Map<String, dynamic> alat) {
    final index = items.indexWhere((i) => i['id_alat'] == alat['id_alat']);
    if (index >= 0) {
      items[index]['qty'] = (items[index]['qty'] ?? 1) + 1;
    } else {
      items.add({...alat, 'qty': 1});
    }
  }

  void setItems(List<Map<String, dynamic>> newItems) {
    items = newItems.map((e) => {...e}).toList();
  }
  
  void clear() {
  items.clear();
}
}
