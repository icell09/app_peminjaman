import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postgrest/postgrest.dart';

import '../../services/alat_service.dart';

class AlatAdmin extends StatefulWidget {
  const AlatAdmin({super.key});

  @override
  State<AlatAdmin> createState() => _AlatAdminState();
}

class _AlatAdminState extends State<AlatAdmin> {
  final _svc = AlatSupabaseService();

  String _searchQuery = "";
  bool _isAlatTab = true;
  bool _loading = true;

  // null => semua
  int? _selectedKategoriId;

  // {id_kategori:int, nama_kategori:String}
  final List<Map<String, dynamic>> _kategoriDb = [];

  // alat list
  final List<Map<String, dynamic>> _allAlat = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      await Future.wait([_loadKategori(), _loadAlat()]);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadKategori() async {
    try {
      final data = await _svc.fetchKategori();
      setState(() {
        _kategoriDb
          ..clear()
          ..addAll(data.map((e) => {
                'id_kategori': (e['id_kategori'] as num).toInt(),
                'nama_kategori': e['nama_kategori'] as String,
              }));
      });
    } catch (e) {
      _toast("Gagal load kategori: ${_svc.prettyDbError(e)}");
    }
  }

  Future<void> _loadAlat() async {
    try {
      final data = await _svc.fetchAlat();
      setState(() {
        _allAlat
          ..clear()
          ..addAll(data.map((e) => {
                'id_alat': e['id_alat'],
                'nama_alat': e['nama_alat'],
                'stok': (e['stok'] as num).toInt(),
                'id_kategori': (e['id_kategori'] as num?)?.toInt(),
                'gambar': e['gambar'],
                'status': e['status'],
              }));
      });
    } catch (e) {
      _toast("Gagal load alat: ${_svc.prettyDbError(e)}");
    }
  }

  String _kategoriIdToName(int? id) {
    if (id == null) return "Uncategorized";
    final k = _kategoriDb.firstWhere(
      (e) => (e['id_kategori'] as int) == id,
      orElse: () => {},
    );
    return (k['nama_kategori'] as String?) ?? "Uncategorized";
  }

  int _countToolsByCategoryId(int idKategori) {
    return _allAlat.where((a) => (a['id_kategori'] as int?) == idKategori).length;
  }

  // ==========================
  // CRUD: ALAT
  // ==========================
  void _openTambahAlat() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => TambahAlatDialog(
        categories: _kategoriDb,
        onSubmit: (data) async {
          try {
            final Uint8List bytes = data['fotoBytes'] as Uint8List;
            final String filename = (data['fotoFilename'] as String?) ?? 'foto.jpg';

            final String gambar = await _svc.uploadFoto(bytes: bytes, filename: filename);

            await _svc.tambahAlat(
              namaAlat: data['nama'] as String,
              stok: data['stok'] as int,
              idKategori: data['kategoriId'] as int,
              gambar: gambar,
            );

            if (mounted) Navigator.pop(context);
            _toast('Alat berhasil ditambahkan');
            await _loadAlat();
          } catch (e) {
            _toast("Gagal tambah alat: ${_svc.prettyDbError(e)}");
          }
        },
      ),
    );
  }

  void _openEditAlat(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => EditAlatDialog(
        categories: _kategoriDb,
        initialNama: item['nama_alat'] as String,
        initialStok: (item['stok'] as int).toString(),
        initialKategoriId: item['id_kategori'] as int?,
        initialFotoUrl: item['gambar'] as String?,
        onSubmit: (data) async {
          try {
            final String idAlat = item['id_alat'] as String;
            final Uint8List? newBytes = data['fotoBytes'] as Uint8List?;
            final String filename = (data['fotoFilename'] as String?) ?? 'foto.jpg';
            final int idKategori = data['kategoriId'] as int;

            String gambarFinal = (item['gambar'] as String?) ?? '';
            if (newBytes != null) {
              gambarFinal = await _svc.uploadFoto(bytes: newBytes, filename: filename);
            }

            await _svc.updateAlat(
              idAlat: idAlat,
              namaAlat: data['nama'] as String,
              stok: data['stok'] as int,
              idKategori: idKategori,
              gambar: gambarFinal,
            );

            if (mounted) Navigator.pop(context);
            _toast("Alat berhasil diupdate");
            await _loadAlat();
          } catch (e) {
            _toast("Gagal update alat: ${_svc.prettyDbError(e)}");
          }
        },
      ),
    );
  }

  void _openDeleteAlat(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Alat"),
        content: Text('Apakah anda yakin ingin menghapus "${item['nama_alat']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                final String idAlat = item['id_alat'] as String;
                await _svc.deleteAlat(idAlat);
                if (mounted) Navigator.pop(context);
                _toast("Alat berhasil dihapus");
                await _loadAlat();
              } catch (e) {
                _toast("Gagal hapus alat: ${_svc.prettyDbError(e)}");
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================
  // CRUD: KATEGORI
  // ==========================
  void _openTambahKategori() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => KategoriFormDialog(
        title: "Tambah Kategori",
        initialName: "",
        readOnlyCount: null,
        onSubmit: (name) async {
          final newName = name.trim();
          if (newName.isEmpty) return;

          // ✅ validasi duplikat (case-insensitive) di Flutter
          final exists = _kategoriDb.any((k) =>
              (k['nama_kategori'] as String).toLowerCase() == newName.toLowerCase());
          if (exists) {
            _toast("Kategori sudah ada");
            return;
          }

          try {
            await _svc.tambahKategori(nama: newName);
            if (mounted) Navigator.pop(context);
            _toast("Kategori berhasil ditambahkan");
            await _loadKategori();
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              _toast("Kategori sudah ada");
            } else {
              _toast("Gagal tambah kategori: ${e.message}");
            }
          } catch (e) {
            _toast("Gagal tambah kategori: ${_svc.prettyDbError(e)}");
          }
        },
      ),
    );
  }

  void _openEditKategoriDb(int id, String oldName, int count) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => KategoriFormDialog(
        title: "Edit Kategori",
        initialName: oldName,
        readOnlyCount: count,
        onSubmit: (newNameRaw) async {
          final newName = newNameRaw.trim();
          if (newName.isEmpty) return;
          if (newName.toLowerCase() == oldName.toLowerCase()) {
            Navigator.pop(context);
            return;
          }

          // ✅ validasi duplikat nama kategori (selain dirinya sendiri)
          final exists = _kategoriDb.any((k) {
            final nama = (k['nama_kategori'] as String);
            final kid = (k['id_kategori'] as int);
            return kid != id && nama.toLowerCase() == newName.toLowerCase();
          });
          if (exists) {
            _toast("Nama kategori sudah dipakai");
            return;
          }

          try {
            await _svc.updateKategori(idKategori: id, nama: newName);
            if (mounted) Navigator.pop(context);
            _toast("Kategori berhasil diupdate");
            await _loadKategori();
          } catch (e) {
            _toast("Gagal update kategori: ${_svc.prettyDbError(e)}");
          }
        },
      ),
    );
  }

  void _openDeleteKategoriDb(int id, String name, int count) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Kategori"),
        content: Text(
          count > 0
              ? 'Kategori "$name" punya $count alat. Jika dihapus, alat bisa orphan kecuali FK di DB pakai ON DELETE SET NULL/RESTRICT. Lanjut hapus?'
              : 'Apakah anda yakin ingin menghapus kategori "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                await _svc.deleteKategori(id);

                if (_selectedKategoriId == id) {
                  setState(() => _selectedKategoriId = null);
                }

                if (mounted) Navigator.pop(context);
                _toast("Kategori berhasil dihapus");
                await Future.wait([_loadKategori(), _loadAlat()]);
              } catch (e) {
                _toast("Gagal hapus kategori: ${_svc.prettyDbError(e)}");
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    final filteredAlat = _allAlat.where((item) {
      final matchesSearch = (item['nama_alat'] as String)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      final matchesKategori =
          _selectedKategoriId == null || (item['id_kategori'] as int?) == _selectedKategoriId;

      return matchesSearch && matchesKategori;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
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
                          Text('Alat',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Kelola dan pantau ketersediaan alat laboratorium',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: _isAlatTab ? 'Cari alat ...' : 'Cari (hanya memfilter alat) ...',
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
                        _buildFilterKategoriPopup(),
                      ],
                    ),
                  ),
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
                  Expanded(
                    child: _isAlatTab ? _buildAlatContent(filteredAlat) : _buildKategoriContent(),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isAlatTab ? _openTambahAlat : _openTambahKategori,
        backgroundColor: const Color(0xFF0061CD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterKategoriPopup() {
    return PopupMenuButton<int?>(
      onSelected: (val) => setState(() => _selectedKategoriId = val),
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
              _selectedKategoriId == null ? "Semua" : _kategoriIdToName(_selectedKategoriId),
              style: const TextStyle(
                  color: Color(0xFF0061CD), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0061CD)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<int?>(value: null, child: Text("Semua")),
        ..._kategoriDb.map((k) {
          final id = (k['id_kategori'] as int);
          final nama = (k['nama_kategori'] as String);
          return PopupMenuItem<int?>(value: id, child: Text(nama));
        }).toList(),
      ],
    );
  }

  Widget _buildAlatContent(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text("Alat tidak ditemukan"));

    return RefreshIndicator(
      onRefresh: _loadAlat,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final String? fotoUrl = item['gambar'] as String?;

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
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (fotoUrl == null || fotoUrl.isEmpty)
                        ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF0061CD))
                        : Image.network(
                            fotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, color: Color(0xFF0061CD)),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['nama_alat'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        "${_kategoriIdToName(item['id_kategori'] as int?)} • Stok: ${item['stok']}",
                        style: const TextStyle(color: Colors.blue, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _openEditAlat(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _openDeleteAlat(item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKategoriContent() {
    if (_kategoriDb.isEmpty) return const Center(child: Text("Kategori belum ada"));

    return RefreshIndicator(
      onRefresh: _loadKategori,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _kategoriDb.length,
        itemBuilder: (context, index) {
          final k = _kategoriDb[index];
          final id = (k['id_kategori'] as int);
          final nama = (k['nama_kategori'] as String);
          final count = _countToolsByCategoryId(id);

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
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_outlined, color: Color(0xFF0061CD)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("$count Alat", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _openEditKategoriDb(id, nama, count),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _openDeleteKategoriDb(id, nama, count),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =====================
// DIALOG FORM KATEGORI
// =====================
class KategoriFormDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final int? readOnlyCount;
  final void Function(String name) onSubmit;

  const KategoriFormDialog({
    super.key,
    required this.title,
    required this.initialName,
    required this.readOnlyCount,
    required this.onSubmit,
  });

  @override
  State<KategoriFormDialog> createState() => _KategoriFormDialogState();
}

class _KategoriFormDialogState extends State<KategoriFormDialog> {
  late final TextEditingController _nameC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('Nama Kategori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _nameC,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan nama kategori",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              if (widget.readOnlyCount != null) ...[
                const SizedBox(height: 12),
                Text("Alat di kategori: ${widget.readOnlyCount}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => widget.onSubmit(_nameC.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0061CD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Simpan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// DIALOG TAMBAH ALAT
// =====================
class TambahAlatDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories; // {id_kategori, nama_kategori}
  final void Function(Map<String, dynamic> data) onSubmit;

  const TambahAlatDialog({
    super.key,
    required this.categories,
    required this.onSubmit,
  });

  @override
  State<TambahAlatDialog> createState() => _TambahAlatDialogState();
}

class _TambahAlatDialogState extends State<TambahAlatDialog> {
  late final TextEditingController _namaC;
  late final TextEditingController _stokC;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoBytes;
  String? _fotoFilename;

  int? _selectedKategoriId;
  bool _loading = false;

  bool _showError = false;
  String? _errFoto;
  String? _errNama;
  String? _errStok;
  String? _errKategori;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController();
    _stokC = TextEditingController();
  }

  @override
  void dispose() {
    _namaC.dispose();
    _stokC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _fotoBytes = bytes;
      _fotoFilename = pickedFile.name;
      if (_showError) _errFoto = null;
    });
  }

  bool _validate() {
    String? errFoto;
    String? errNama;
    String? errStok;
    String? errKategori;

    if (_fotoBytes == null) errFoto = "Foto wajib dipilih";
    if (_namaC.text.trim().isEmpty) errNama = "Nama alat wajib diisi";

    final stokRaw = _stokC.text.trim();
    if (stokRaw.isEmpty) {
      errStok = "Stok wajib diisi";
    } else {
      final stokVal = int.tryParse(stokRaw);
      if (stokVal == null) errStok = "Stok harus berupa angka";
      if (stokVal != null && stokVal < 0) errStok = "Stok tidak boleh minus";
    }

    if (_selectedKategoriId == null) errKategori = "Kategori wajib dipilih";

    setState(() {
      _errFoto = errFoto;
      _errNama = errNama;
      _errStok = errStok;
      _errKategori = errKategori;
    });

    return errFoto == null && errNama == null && errStok == null && errKategori == null;
  }

  Future<void> _submit() async {
    setState(() => _showError = true);
    final ok = _validate();
    if (!ok) return;

    setState(() => _loading = true);
    try {
      widget.onSubmit({
        'nama': _namaC.text.trim(),
        'stok': int.parse(_stokC.text.trim()),
        'kategoriId': _selectedKategoriId!,
        'fotoBytes': _fotoBytes!,
        'fotoFilename': _fotoFilename ?? 'foto.jpg',
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tambah Alat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),

              const Text('Foto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _fotoBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_fotoBytes!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate, color: Color(0xFF0061CD)),
                              SizedBox(height: 6),
                              Text("Pilih Foto",
                                  style: TextStyle(color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ),
                ),
              ),
              if (_showError && _errFoto != null) ...[
                const SizedBox(height: 6),
                Text(_errFoto!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 14),

              const Text('Nama Alat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _box(
                child: TextField(
                  controller: _namaC,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan nama alat",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) {
                    if (_showError) setState(() => _errNama = null);
                  },
                ),
              ),
              if (_showError && _errNama != null) ...[
                const SizedBox(height: 6),
                Text(_errNama!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 12),

              const Text('Stok', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _box(
                child: TextField(
                  controller: _stokC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan jumlah stok",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) {
                    if (_showError) setState(() => _errStok = null);
                  },
                ),
              ),
              if (_showError && _errStok != null) ...[
                const SizedBox(height: 6),
                Text(_errStok!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 12),

              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _box(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedKategoriId,
                    hint: const Text("Pilih kategori",
                        style: TextStyle(color: Colors.black38, fontSize: 12)),
                    items: widget.categories.map((e) {
                      final id = (e['id_kategori'] as int);
                      final nama = (e['nama_kategori'] as String);
                      return DropdownMenuItem<int>(value: id, child: Text(nama));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedKategoriId = val;
                        if (_showError) _errKategori = null;
                      });
                    },
                  ),
                ),
              ),
              if (_showError && _errKategori != null) ...[
                const SizedBox(height: 6),
                Text(_errKategori!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0061CD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Tambah",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

// =====================
// DIALOG EDIT ALAT
// =====================
class EditAlatDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String initialNama;
  final String initialStok;
  final int? initialKategoriId;
  final String? initialFotoUrl;
  final void Function(Map<String, dynamic> data) onSubmit;

  const EditAlatDialog({
    super.key,
    required this.categories,
    required this.initialNama,
    required this.initialStok,
    required this.initialKategoriId,
    required this.initialFotoUrl,
    required this.onSubmit,
  });

  @override
  State<EditAlatDialog> createState() => _EditAlatDialogState();
}

class _EditAlatDialogState extends State<EditAlatDialog> {
  late final TextEditingController _namaC;
  late final TextEditingController _stokC;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoBytes;
  String? _fotoFilename;

  int? _selectedKategoriId;
  bool _loading = false;

  bool _showError = false;
  String? _errNama;
  String? _errStok;
  String? _errKategori;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.initialNama);
    _stokC = TextEditingController(text: widget.initialStok);
    _selectedKategoriId = widget.initialKategoriId;
  }

  @override
  void dispose() {
    _namaC.dispose();
    _stokC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _fotoBytes = bytes;
      _fotoFilename = pickedFile.name;
    });
  }

  bool _validate() {
    String? errNama;
    String? errStok;
    String? errKategori;

    if (_namaC.text.trim().isEmpty) errNama = "Nama alat wajib diisi";

    final stokRaw = _stokC.text.trim();
    if (stokRaw.isEmpty) {
      errStok = "Stok wajib diisi";
    } else {
      final stokVal = int.tryParse(stokRaw);
      if (stokVal == null) errStok = "Stok harus berupa angka";
      if (stokVal != null && stokVal < 0) errStok = "Stok tidak boleh minus";
    }

    if (_selectedKategoriId == null) errKategori = "Kategori wajib dipilih";

    setState(() {
      _errNama = errNama;
      _errStok = errStok;
      _errKategori = errKategori;
    });

    return errNama == null && errStok == null && errKategori == null;
  }

  Future<void> _submit() async {
    setState(() => _showError = true);
    final ok = _validate();
    if (!ok) return;

    setState(() => _loading = true);
    try {
      widget.onSubmit({
        'nama': _namaC.text.trim(),
        'stok': int.parse(_stokC.text.trim()),
        'kategoriId': _selectedKategoriId!,
        'fotoBytes': _fotoBytes, // nullable
        'fotoFilename': _fotoFilename ?? 'foto.jpg',
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Alat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),

              const Text('Foto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _fotoBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_fotoBytes!, fit: BoxFit.cover),
                        )
                      : (widget.initialFotoUrl != null && widget.initialFotoUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.initialFotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, color: Color(0xFF0061CD)),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.add_photo_alternate, color: Color(0xFF0061CD)),
                            ),
                ),
              ),

              const SizedBox(height: 14),

              const Text('Nama Alat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _box(
                child: TextField(
                  controller: _namaC,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan nama alat",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) {
                    if (_showError) setState(() => _errNama = null);
                  },
                ),
              ),
              if (_showError && _errNama != null) ...[
                const SizedBox(height: 6),
                Text(_errNama!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 12),

              const Text('Stok', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _box(
                child: TextField(
                  controller: _stokC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan jumlah stok",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) {
                    if (_showError) setState(() => _errStok = null);
                  },
                ),
              ),
              if (_showError && _errStok != null) ...[
                const SizedBox(height: 6),
                Text(_errStok!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 12),

              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _box(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedKategoriId,
                    hint: const Text("Pilih kategori",
                        style: TextStyle(color: Colors.black38, fontSize: 12)),
                    items: widget.categories.map((e) {
                      final id = (e['id_kategori'] as int);
                      final nama = (e['nama_kategori'] as String);
                      return DropdownMenuItem<int>(value: id, child: Text(nama));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedKategoriId = val;
                        if (_showError) _errKategori = null;
                      });
                    },
                  ),
                ),
              ),
              if (_showError && _errKategori != null) ...[
                const SizedBox(height: 6),
                Text(_errKategori!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0061CD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Simpan",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
