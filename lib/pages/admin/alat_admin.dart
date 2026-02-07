import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class AlatAdmin extends StatefulWidget {
  const AlatAdmin({super.key});

  @override
  State<AlatAdmin> createState() => _AlatAdminState();
}

class _AlatAdminState extends State<AlatAdmin> {
  // --- STATE ---
  String _searchQuery = "";
  String _selectedKategori = "Semua";
  bool _isAlatTab = true;

  // Kategori bisa CRUD (jangan hapus "Semua")
  final List<String> _kategoriList = [
    "Semua",
    "Perangkat Keras",
    "Perangkat Penyimpanan",
    "Perangkat Jaringan",
    "Perangkat Output",
  ];

  // Data alat (web-safe: fotoBytes)
  final List<Map<String, dynamic>> _allAlat = [
    {
      'nama': 'Logitech G305',
      'stok': 16,
      'kategori': 'Perangkat Keras',
      'fotoBytes': null,
    },
    {
      'nama': 'SSD Samsung 1TB',
      'stok': 5,
      'kategori': 'Perangkat Penyimpanan',
      'fotoBytes': null,
    },
    {
      'nama': 'Router TP-Link',
      'stok': 8,
      'kategori': 'Perangkat Jaringan',
      'fotoBytes': null,
    },
    {
      'nama': 'Monitor Dell 24"',
      'stok': 12,
      'kategori': 'Perangkat Output',
      'fotoBytes': null,
    },
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  int _countToolsByCategory(String categoryName) {
    return _allAlat.where((a) => a['kategori'] == categoryName).length;
  }

  // ==========================
  // CRUD: ALAT
  // ==========================
  void _openTambahAlat() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => TambahAlatDialog(
            categories: _kategoriList.where((e) => e != "Semua").toList(),
            onSubmit: (data) {
              setState(() {
                _allAlat.insert(0, {
                  'nama': data['nama'],
                  'stok': data['stok'],
                  'kategori': data['kategori'],
                  'fotoBytes': data['fotoBytes'],
                });
              });
              Navigator.pop(context);
              _toast('Alat berhasil ditambahkan');
            },
          ),
    );
  }

  void _openEditAlat(Map<String, dynamic> item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => EditAlatDialog(
            categories: _kategoriList.where((e) => e != "Semua").toList(),
            initialNama: item['nama'] as String,
            initialStok: (item['stok'] as int).toString(),
            initialKategori: item['kategori'] as String,
            initialFotoBytes: item['fotoBytes'] as Uint8List?,
            onSubmit: (data) {
              setState(() {
                item['nama'] = data['nama'];
                item['stok'] = data['stok'];
                item['kategori'] = data['kategori'];
                item['fotoBytes'] = data['fotoBytes'];
              });
              Navigator.pop(context);
              _toast("Alat berhasil diupdate");
            },
          ),
    );
  }

  void _openDeleteAlat(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hapus Alat"),
            content: Text(
              'Apakah anda yakin ingin menghapus "${item['nama']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() => _allAlat.remove(item));
                  Navigator.pop(context);
                  _toast("Alat berhasil dihapus");
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.white),
                ),
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
      builder:
          (_) => KategoriFormDialog(
            title: "Tambah Kategori",
            initialName: "",
            readOnlyCount: null,
            onSubmit: (name) {
              final newName = name.trim();
              if (newName.isEmpty) return;

              final exists = _kategoriList
                  .where((k) => k != "Semua")
                  .any((k) => k.toLowerCase() == newName.toLowerCase());

              if (exists) {
                _toast("Kategori sudah ada");
                return;
              }

              setState(() => _kategoriList.add(newName));
              Navigator.pop(context);
              _toast("Kategori berhasil ditambahkan");
            },
          ),
    );
  }

  void _openEditKategori(String oldName) {
    final count = _countToolsByCategory(oldName);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => KategoriFormDialog(
            title: "Edit Kategori",
            initialName: oldName,
            readOnlyCount: count,
            onSubmit: (newNameRaw) {
              final newName = newNameRaw.trim();
              if (newName.isEmpty) return;

              if (newName == oldName) {
                Navigator.pop(context);
                return;
              }

              final exists = _kategoriList
                  .where((k) => k != "Semua")
                  .any((k) => k.toLowerCase() == newName.toLowerCase());
              if (exists) {
                _toast("Nama kategori sudah dipakai");
                return;
              }

              setState(() {
                final idx = _kategoriList.indexOf(oldName);
                if (idx != -1) _kategoriList[idx] = newName;

                if (_selectedKategori == oldName) _selectedKategori = newName;

                for (final a in _allAlat) {
                  if (a['kategori'] == oldName) a['kategori'] = newName;
                }
              });

              Navigator.pop(context);
              _toast("Kategori berhasil diupdate");
            },
          ),
    );
  }

  void _openDeleteKategori(String name) {
    final count = _countToolsByCategory(name);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hapus Kategori"),
            content: Text(
              count > 0
                  ? 'Kategori "$name" punya $count alat. Jika dihapus, alat dipindah ke "Uncategorized". Lanjut?'
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (!_kategoriList.contains("Uncategorized")) {
                      _kategoriList.add("Uncategorized");
                    }
                    for (final a in _allAlat) {
                      if (a['kategori'] == name)
                        a['kategori'] = "Uncategorized";
                    }
                    _kategoriList.remove(name);
                    if (_selectedKategori == name) _selectedKategori = "Semua";
                  });

                  Navigator.pop(context);
                  _toast("Kategori berhasil dihapus");
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.white),
                ),
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
    final filteredAlat =
        _allAlat.where((item) {
          final matchesSearch = (item['nama'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesKategori =
              _selectedKategori == "Semua" ||
              item['kategori'] == _selectedKategori;
          return matchesSearch && matchesKategori;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                    Text(
                      'Alat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola dan pantau ketersediaan alat laboratorium',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
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
                      onChanged:
                          (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText:
                            _isAlatTab
                                ? 'Cari alat ...'
                                : 'Cari (hanya memfilter alat) ...',
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
                      alignment:
                          _isAlatTab
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
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
                                  color:
                                      _isAlatTab ? Colors.white : Colors.grey,
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
                                  color:
                                      !_isAlatTab ? Colors.white : Colors.grey,
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
              child:
                  _isAlatTab
                      ? _buildAlatContent(filteredAlat)
                      : _buildKategoriContent(),
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
            const Icon(
              Icons.filter_alt_outlined,
              color: Color(0xFF0061CD),
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              _selectedKategori,
              style: const TextStyle(
                color: Color(0xFF0061CD),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0061CD)),
          ],
        ),
      ),
      itemBuilder:
          (context) =>
              _kategoriList
                  .map((item) => PopupMenuItem(value: item, child: Text(item)))
                  .toList(),
    );
  }

  // =======================
  // LIST ALAT (EDIT + DELETE)
  // =======================
  Widget _buildAlatContent(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text("Alat tidak ditemukan"));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final Uint8List? fotoBytes = item['fotoBytes'] as Uint8List?;

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
                  child:
                      fotoBytes == null
                          ? const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF0061CD),
                          )
                          : Image.memory(fotoBytes, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${item['kategori']} • Stok: ${item['stok']}",
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
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                    size: 18,
                  ),
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
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =======================
  // LIST KATEGORI (EDIT + DELETE)
  // =======================
  Widget _buildKategoriContent() {
    final list = _kategoriList.where((k) => k != "Semua").toList();
    if (list.isEmpty) return const Center(child: Text("Kategori belum ada"));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final kategori = list[index];
        final count = _countToolsByCategory(kategori);

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
                child: const Icon(
                  Icons.folder_outlined,
                  color: Color(0xFF0061CD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kategori,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$count Alat",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _openEditKategori(kategori),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _openDeleteKategori(kategori),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================
// DIALOG TAMBAH ALAT (UPLOAD FOTO - WEB SAFE)
// =====================
class TambahAlatDialog extends StatefulWidget {
  const TambahAlatDialog({
    super.key,
    required this.categories,
    required this.onSubmit,
  });

  final List<String> categories;
  final void Function(Map<String, dynamic> data) onSubmit;

  @override
  State<TambahAlatDialog> createState() => _TambahAlatDialogState();
}

class _TambahAlatDialogState extends State<TambahAlatDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaC = TextEditingController();
  final TextEditingController _stokC = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? _pickedBytes;
  String? _kategori;
  bool _loading = false;

  @override
  void dispose() {
    _namaC.dispose();
    _stokC.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (img == null) return;

      final bytes = await img.readAsBytes();
      setState(() => _pickedBytes = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal pilih foto: $e')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto alat wajib dipilih dari galeri')),
      );
      return;
    }
    if (_kategori == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori wajib dipilih')));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    widget.onSubmit({
      'nama': _namaC.text.trim(),
      'stok': int.tryParse(_stokC.text.trim()) ?? 0,
      'kategori': _kategori!,
      'fotoBytes': _pickedBytes,
    });

    setState(() => _loading = false);
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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Alat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child:
                        _pickedBytes == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Color(0xFF0061CD),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Pilih Foto dari Galeri',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tap untuk pilih foto',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    _pickedBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: InkWell(
                                      onTap:
                                          () => setState(
                                            () => _pickedBytes = null,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Nama Alat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _input(
                  controller: _namaC,
                  hint: 'tambahkan nama alat',
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Nama alat wajib diisi'
                              : null,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Stok',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _input(
                  controller: _stokC,
                  hint: 'tambahkan stok',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Stok wajib diisi';
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Stok harus angka';
                    if (n < 0) return 'Stok tidak boleh minus';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _kategori,
                      isExpanded: true,
                      hint: const Text(
                        'pilih kategori produk',
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                      items:
                          widget.categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _kategori = v),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed:
                              _loading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _loading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// =====================
// DIALOG EDIT ALAT (UPDATE + GANTI FOTO)
// =====================
class EditAlatDialog extends StatefulWidget {
  const EditAlatDialog({
    super.key,
    required this.categories,
    required this.initialNama,
    required this.initialStok,
    required this.initialKategori,
    required this.initialFotoBytes,
    required this.onSubmit,
  });

  final List<String> categories;
  final String initialNama;
  final String initialStok;
  final String initialKategori;
  final Uint8List? initialFotoBytes;

  final void Function(Map<String, dynamic> data) onSubmit;

  @override
  State<EditAlatDialog> createState() => _EditAlatDialogState();
}

class _EditAlatDialogState extends State<EditAlatDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaC;
  late final TextEditingController _stokC;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _pickedBytes;
  String? _kategori;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.initialNama);
    _stokC = TextEditingController(text: widget.initialStok);
    _kategori = widget.initialKategori;
    _pickedBytes = widget.initialFotoBytes;
  }

  @override
  void dispose() {
    _namaC.dispose();
    _stokC.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (img == null) return;
      final bytes = await img.readAsBytes();
      setState(() => _pickedBytes = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal pilih foto: $e')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto alat wajib ada')));
      return;
    }
    if (_kategori == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori wajib dipilih')));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 150));

    widget.onSubmit({
      'nama': _namaC.text.trim(),
      'stok': int.tryParse(_stokC.text.trim()) ?? 0,
      'kategori': _kategori!,
      'fotoBytes': _pickedBytes,
    });

    setState(() => _loading = false);
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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Alat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child:
                        _pickedBytes == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Color(0xFF0061CD),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Pilih Foto dari Galeri',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    _pickedBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Ganti",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Nama Alat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _boxInput(
                  child: TextFormField(
                    controller: _namaC,
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Nama alat wajib diisi'
                                : null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'nama alat',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Stok',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _boxInput(
                  child: TextFormField(
                    controller: _stokC,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Stok wajib diisi';
                      final n = int.tryParse(v.trim());
                      if (n == null) return 'Stok harus angka';
                      if (n < 0) return 'Stok tidak boleh minus';
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'stok',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _kategori,
                      isExpanded: true,
                      items:
                          widget.categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _kategori = v),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed:
                              _loading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _loading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Simpan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _boxInput({required Widget child}) {
    return Container(
      height: 46,
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
// DIALOG TAMBAH/EDIT KATEGORI
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
    required this.onSubmit,
    this.readOnlyCount,
  });

  @override
  State<KategoriFormDialog> createState() => _KategoriFormDialogState();
}

class _KategoriFormDialogState extends State<KategoriFormDialog> {
  final _formKey = GlobalKey<FormState>();
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
    final isEdit = widget.readOnlyCount != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Nama Kategori',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 6),
              _boxInput(
                child: TextFormField(
                  controller: _nameC,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "Nama kategori wajib diisi";
                    if (v.trim().length < 2) return "Minimal 2 karakter";
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan nama kategori",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              if (isEdit) ...[
                const SizedBox(height: 12),
                const Text(
                  'Jumlah Alat',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _boxInput(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: "${widget.readOnlyCount} Alat",
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          widget.onSubmit(_nameC.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0061CD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEdit ? "Simpan" : "Tambah",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
    );
  }

  Widget _boxInput({required Widget child}) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
