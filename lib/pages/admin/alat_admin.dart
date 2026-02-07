import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =====================
// SUPABASE SERVICE (CRUD ALAT + UPLOAD FOTO)
// =====================
class AlatSupabaseService {
  final SupabaseClient _db = Supabase.instance.client;

  // ✅ FIX: created_at DIHAPUS karena kolomnya tidak ada di tabel
  Future<List<Map<String, dynamic>>> fetchAlat() async {
    final res = await _db
        .from('alat')
        .select('id_alat,nama_alat,stok,id_kategori,gambar,status')
        .order('nama_alat', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<String> uploadFoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeName = filename.isEmpty ? 'foto.jpg' : filename;
    final path = 'alat/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await _db.storage.from('alat-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    // bucket public
    return _db.storage.from('alat-images').getPublicUrl(path);
  }

  Future<void> tambahAlat({
    required String namaAlat,
    required int stok,
    required int idKategori,
    required String gambar,
    String status = 'tersedia',
  }) async {
    await _db.from('alat').insert({
      'nama_alat': namaAlat,
      'stok': stok,
      'id_kategori': idKategori,
      'gambar': gambar,
      'status': status,
    });
  }

  Future<void> updateAlat({
    required String idAlat, // uuid string
    required String namaAlat,
    required int stok,
    required int idKategori,
    required String gambar,
    String? status,
  }) async {
    final data = <String, dynamic>{
      'nama_alat': namaAlat,
      'stok': stok,
      'id_kategori': idKategori,
      'gambar': gambar,
    };
    if (status != null) data['status'] = status;

    await _db.from('alat').update(data).eq('id_alat', idAlat);
  }

  Future<void> deleteAlat(String idAlat) async {
    await _db.from('alat').delete().eq('id_alat', idAlat);
  }
}

// =====================
// PAGE
// =====================
class AlatAdmin extends StatefulWidget {
  const AlatAdmin({super.key});

  @override
  State<AlatAdmin> createState() => _AlatAdminState();
}

class _AlatAdminState extends State<AlatAdmin> {
  final _svc = AlatSupabaseService();

  String _searchQuery = "";
  String _selectedKategori = "Semua";
  bool _isAlatTab = true;
  bool _loadingAlat = true;

  // Kategori lokal (yang tampil di UI)
  final List<String> _kategoriList = [
    "Semua",
    "Perangkat Keras",
    "Perangkat Penyimpanan",
    "Perangkat Jaringan",
    "Perangkat Output",
  ];

  final List<Map<String, dynamic>> _allAlat = [];

  @override
  void initState() {
    super.initState();
    _loadAlat();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // mapping kategori lokal <-> id_kategori (asumsi 1..n sesuai urutan list tanpa "Semua")
  int _kategoriNameToId(String namaKategori) {
    final list = _kategoriList.where((e) => e != "Semua").toList();
    final idx = list.indexOf(namaKategori);
    return idx == -1 ? 0 : (idx + 1);
  }

  String _kategoriIdToName(int? idKategori) {
    final list = _kategoriList.where((e) => e != "Semua").toList();
    if (idKategori == null || idKategori <= 0 || idKategori > list.length) {
      return "Uncategorized";
    }
    return list[idKategori - 1];
  }

  Future<void> _loadAlat() async {
    setState(() => _loadingAlat = true);
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
      _toast("Gagal load alat: $e");
    } finally {
      if (mounted) setState(() => _loadingAlat = false);
    }
  }

  int _countToolsByCategory(String categoryName) {
    final int id = _kategoriNameToId(categoryName);
    return _allAlat.where((a) => (a['id_kategori'] as int?) == id).length;
  }

  // ==========================
  // CRUD: ALAT
  // ==========================
  void _openTambahAlat() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => TambahAlatDialog(
        categories: _kategoriList.where((e) => e != "Semua").toList(),
        onSubmit: (data) async {
          try {
            final Uint8List bytes = data['fotoBytes'] as Uint8List;
            final String filename =
                (data['fotoFilename'] as String?) ?? 'foto.jpg';

            final String gambar =
                await _svc.uploadFoto(bytes: bytes, filename: filename);

            await _svc.tambahAlat(
              namaAlat: data['nama'] as String,
              stok: data['stok'] as int,
              idKategori: _kategoriNameToId(data['kategori'] as String),
              gambar: gambar,
            );

            if (mounted) Navigator.pop(context);
            _toast('Alat berhasil ditambahkan');
            await _loadAlat();
          } catch (e) {
            _toast("Gagal tambah alat: $e");
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
        categories: _kategoriList.where((e) => e != "Semua").toList(),
        initialNama: item['nama_alat'] as String,
        initialStok: (item['stok'] as int).toString(),
        initialKategori: _kategoriIdToName(item['id_kategori'] as int?),
        initialFotoUrl: item['gambar'] as String?,
        onSubmit: (data) async {
          try {
            final String idAlat = item['id_alat'] as String;

            final Uint8List? newBytes = data['fotoBytes'] as Uint8List?;
            final String filename =
                (data['fotoFilename'] as String?) ?? 'foto.jpg';

            final int idKategori =
                _kategoriNameToId(data['kategori'] as String);

            if (newBytes != null) {
              final String newGambar =
                  await _svc.uploadFoto(bytes: newBytes, filename: filename);

              await _svc.updateAlat(
                idAlat: idAlat,
                namaAlat: data['nama'] as String,
                stok: data['stok'] as int,
                idKategori: idKategori,
                gambar: newGambar,
              );
            } else {
              await _svc.updateAlat(
                idAlat: idAlat,
                namaAlat: data['nama'] as String,
                stok: data['stok'] as int,
                idKategori: idKategori,
                gambar: (item['gambar'] as String?) ?? '',
              );
            }

            if (mounted) Navigator.pop(context);
            _toast("Alat berhasil diupdate");
            await _loadAlat();
          } catch (e) {
            _toast("Gagal update alat: $e");
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
        content:
            Text('Apakah anda yakin ingin menghapus "${item['nama_alat']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                final String idAlat = item['id_alat'] as String;
                await _svc.deleteAlat(idAlat);
                if (mounted) Navigator.pop(context);
                _toast("Alat berhasil dihapus");
                await _loadAlat();
              } catch (e) {
                _toast("Gagal hapus alat: $e");
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================
  // CRUD: KATEGORI (LOKAL)
  // ==========================
  void _openTambahKategori() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => KategoriFormDialog(
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
      builder: (_) => KategoriFormDialog(
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
      builder: (_) => AlertDialog(
        title: const Text("Hapus Kategori"),
        content: Text(
          count > 0
              ? 'Kategori "$name" punya $count alat. Jika dihapus, itu hanya menghapus dari list lokal. Lanjut?'
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              setState(() {
                _kategoriList.remove(name);
                if (_selectedKategori == name) _selectedKategori = "Semua";
              });
              if (mounted) Navigator.pop(context);
              _toast("Kategori berhasil dihapus (lokal)");
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

      final matchesKategori = _selectedKategori == "Semua" ||
          _kategoriIdToName(item['id_kategori'] as int?) == _selectedKategori;

      return matchesSearch && matchesKategori;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loadingAlat
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
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: _isAlatTab
                                  ? 'Cari alat ...'
                                  : 'Cari (hanya memfilter alat) ...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            alignment: _isAlatTab
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
                                  onTap: () =>
                                      setState(() => _isAlatTab = true),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      "Alat",
                                      style: TextStyle(
                                        color: _isAlatTab
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isAlatTab = false),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      "Kategori",
                                      style: TextStyle(
                                        color: !_isAlatTab
                                            ? Colors.white
                                            : Colors.grey,
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
                    child: _isAlatTab
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
            const Icon(Icons.filter_alt_outlined,
                color: Color(0xFF0061CD), size: 18),
            const SizedBox(width: 4),
            Text(
              _selectedKategori,
              style: const TextStyle(
                  color: Color(0xFF0061CD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0061CD)),
          ],
        ),
      ),
      itemBuilder: (context) => _kategoriList
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
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
                        ? const Icon(Icons.inventory_2_outlined,
                            color: Color(0xFF0061CD))
                        : Image.network(
                            fotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Color(0xFF0061CD)),
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
                        style: const TextStyle(color: Colors.blue, fontSize: 11)),
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
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 18),
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
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
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
                child: const Icon(Icons.folder_outlined,
                    color: Color(0xFF0061CD)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kategori,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("$count Alat",
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.blue, size: 18),
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
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
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
// DIALOG TAMBAH ALAT (FIX UI: Foto di atas, kategori default "Pilih kategori",
// error text tampil di bawah field)
// =====================
class TambahAlatDialog extends StatefulWidget {
  final List<String> categories;
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaC;
  late final TextEditingController _stokC;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoBytes;
  String? _fotoFilename;

  // ✅ default null => hint tampil "Pilih kategori"
  String? _selectedKategori;

  bool _loading = false;

  bool _submitted = false;

  String? _errNama;
  String? _errStok;
  String? _errKategori;
  String? _errFoto;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController();
    _stokC = TextEditingController();
    _selectedKategori = null; // ✅ jangan auto pilih
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
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoFilename = pickedFile.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori wajib dipilih")),
      );
      return;
    }

    if (_fotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih foto terlebih dahulu")),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 150));

    widget.onSubmit({
      'nama': _namaC.text.trim(),
      'stok': int.parse(_stokC.text.trim()),
      'kategori': _selectedKategori!,
      'fotoBytes': _fotoBytes,
      'fotoFilename': _fotoFilename ?? 'foto.jpg',
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
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
          ],
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tambah Alat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),

                const Text('Foto',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
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
                                Icon(Icons.add_photo_alternate,
                                    color: Color(0xFF0061CD)),
                                SizedBox(height: 6),
                                Text("Pilih Foto",
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text('Nama Alat',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 6),
                _boxInputNoFixedHeight(
                  child: TextFormField(
                    controller: _namaC,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Nama alat wajib diisi" : null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukkan nama alat",
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                     onChanged: (_) {
                    if (_submitted && _errNama != null) {
                      setState(() => _errNama = null);
                    }
                   }
                  ),
                ),

                const SizedBox(height: 12),

                const Text('Stok',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 6),
                _boxInputNoFixedHeight(
                  child: TextFormField(
                    controller: _stokC,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Stok wajib diisi";
                      if (int.tryParse(v.trim()) == null) return "Stok harus berupa angka";
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukkan jumlah stok",
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text('Kategori',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 6),
                _boxInputNoFixedHeight(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedKategori,
                      hint: const Text(
                        "Pilih kategori",
                        style: TextStyle(color: Colors.black38, fontSize: 12),
                      ),
                      items: widget.categories
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedKategori = val),
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
                          onPressed: _loading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Batal',
                              style: TextStyle(
                                  color: Colors.black87, fontWeight: FontWeight.w800)),
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
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text("Tambah",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _boxInputNoFixedHeight({required Widget child}) {
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
// DIALOG EDIT ALAT (Foto di atas, error di bawah field)
// =====================
class EditAlatDialog extends StatefulWidget {
  final List<String> categories;
  final String initialNama;
  final String initialStok;
  final String initialKategori;
  final String? initialFotoUrl;
  final void Function(Map<String, dynamic> data) onSubmit;

  const EditAlatDialog({
    super.key,
    required this.categories,
    required this.initialNama,
    required this.initialStok,
    required this.initialKategori,
    required this.initialFotoUrl,
    required this.onSubmit,
  });

  @override
  State<EditAlatDialog> createState() => _EditAlatDialogState();
}

class _EditAlatDialogState extends State<EditAlatDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaC;
  late final TextEditingController _stokC;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoBytes;
  String? _fotoFilename;

  // edit: default kategori dari data lama
  late String? _selectedKategori;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.initialNama);
    _stokC = TextEditingController(text: widget.initialStok);
    _selectedKategori = widget.initialKategori;
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
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoFilename = pickedFile.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori wajib dipilih")),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 150));

    widget.onSubmit({
      'nama': _namaC.text.trim(),
      'stok': int.parse(_stokC.text.trim()),
      'kategori': _selectedKategori!,
      'fotoBytes': _fotoBytes, // boleh null
      'fotoFilename': _fotoFilename ?? 'foto.jpg',
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
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
          ],
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Edit Alat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),

                const Text('Foto',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
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
                        : (widget.initialFotoUrl != null &&
                                widget.initialFotoUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.initialFotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Color(0xFF0061CD)),
                                  ),
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_photo_alternate,
                                        color: Color(0xFF0061CD)),
                                    SizedBox(height: 6),
                                    Text("Pilih Foto Baru",
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 12)),
                                  ],
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text('Nama Alat',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 6),
                _boxInputNoFixedHeight(
                  child: TextFormField(
                    controller: _namaC,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Nama alat wajib diisi" : null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukkan nama alat",
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text('Stok',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 6),
                _boxInputNoFixedHeight(
                  child: TextFormField(
                    controller: _stokC,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Stok wajib diisi";
                      if (int.tryParse(v.trim()) == null) return "Stok harus berupa angka";
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukkan jumlah stok",
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text('Kategori',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 6),
                _boxInputNoFixedHeight(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedKategori,
                      hint: const Text(
                        "Pilih kategori",
                        style: TextStyle(color: Colors.black38, fontSize: 12),
                      ),
                      items: widget.categories
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedKategori = val),
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
                          onPressed: _loading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Batal',
                              style: TextStyle(
                                  color: Colors.black87, fontWeight: FontWeight.w800)),
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
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text("Simpan",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _boxInputNoFixedHeight({required Widget child}) {
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
// DIALOG TAMBAH/EDIT KATEGORI (LOKAL)
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
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('Nama Kategori',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              _boxInputFixedHeight(
                child: TextFormField(
                  controller: _nameC,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Nama kategori wajib diisi";
                    if (v.trim().length < 2) return "Minimal 2 karakter";
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan nama kategori",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(
                                color: Colors.black87, fontWeight: FontWeight.w800)),
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
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isEdit ? "Simpan" : "Tambah",
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800)),
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

  // untuk kategori dialog boleh fixed height karena jarang muncul error panjang
  Widget _boxInputFixedHeight({required Widget child}) {
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
