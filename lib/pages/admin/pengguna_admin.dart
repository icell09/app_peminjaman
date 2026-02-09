import 'package:flutter/material.dart';
import 'package:ukk_peminjaman/services/pengguna_services.dart';
import '../../services/pengguna_services.dart';

<<<<<<< HEAD
=======
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PenggunaAdmin(),
    );
  }
}

/* =======================
   MODEL
======================= */
class PenggunaModel {
  String id;
  String nama;
  String email;
  String role;
  String status;

  PenggunaModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    required this.status,
  });
}

/* =======================
   PAGE ADMIN
======================= */
>>>>>>> 8a311b07cca40b07a2bd8166f3ac8ad1395e49c6
class PenggunaAdmin extends StatefulWidget {
  const PenggunaAdmin({super.key});

  @override
  State<PenggunaAdmin> createState() => _PenggunaAdminState();
}

class _PenggunaAdminState extends State<PenggunaAdmin> {
<<<<<<< HEAD
  final PenggunaAdminController controller = PenggunaAdminController();

  final TextEditingController _searchCtrl = TextEditingController();
  String _filterRole = "Semua";
  bool _loading = false;

  Stream<List<Map<String, dynamic>>> get _streamUsers => controller.streamUsers();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateUser(String id, String nama, String role, String password) async {
    try {
      setState(() => _loading = true);
=======
  final Color primaryBlue = const Color(0xFF0B5ED7);
  final TextEditingController searchCtrl = TextEditingController();
  String filterStatus = "Semua";

  final List<PenggunaModel> pengguna = [
    PenggunaModel(
      id: "1",
      nama: "Arya",
      email: "arya@gmail.com",
      role: "Petugas",
      status: "Aktif",
    ),
    PenggunaModel(
      id: "2",
      nama: "Lula",
      email: "lula@gmail.com",
      role: "Petugas",
      status: "Aktif",
    ),
  ];

  List<PenggunaModel> get filteredPengguna {
    final q = searchCtrl.text.toLowerCase();
    return pengguna.where((p) {
      final searchOk =
          q.isEmpty ||
          p.nama.toLowerCase().contains(q) ||
          p.email.toLowerCase().contains(q);
      final statusOk = filterStatus == "Semua" || p.status == filterStatus;
      return searchOk && statusOk;
    }).toList();
  }

  /* =======================
     TAMBAH / EDIT
  ======================= */
  Future<void> openForm({PenggunaModel? data}) async {
    final result = await showModalBottomSheet<PenggunaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _FormPengguna(
            title: data == null ? "Tambah Pengguna" : "Edit Pengguna",
            initial: data,
            primaryBlue: primaryBlue,
          ),
    );
>>>>>>> 8a311b07cca40b07a2bd8166f3ac8ad1395e49c6

      await controller.updateUser(
        id: id,
        nama: nama,
        role: role,
        password: password.isEmpty ? null : password,
      );

<<<<<<< HEAD
      _showSnackBar("Data $nama berhasil diperbarui", Colors.blue);
    } catch (e) {
      _showSnackBar("Gagal memperbarui (Cek Hak Akses Admin)", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _tambahUser(String email, String password, String nama, String role) async {
    try {
      setState(() => _loading = true);

      await controller.tambahUser(
        email: email,
        password: password,
        nama: nama,
        role: role,
      );

      _showSnackBar("User berhasil ditambahkan", Colors.green);
    } catch (e) {
      _showSnackBar("Gagal menambah: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
=======
    setState(() {
      final i = pengguna.indexWhere((e) => e.id == result.id);
      if (i >= 0) {
        pengguna[i] = result;
      } else {
        pengguna.insert(0, result);
      }
    });
  }

  /* =======================
     DELETE (FIX)
  ======================= */
  Future<void> hapusPengguna(PenggunaModel data) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text("Hapus Pengguna"),
            content: Text("Yakin ingin menghapus ${data.nama}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus"),
              ),
            ],
          ),
    );

    if (ok == true) {
      setState(() => pengguna.removeWhere((e) => e.id == data.id));
>>>>>>> 8a311b07cca40b07a2bd8166f3ac8ad1395e49c6
    }
  }

  Future<void> _hapusUser(String id) async {
    try {
      setState(() => _loading = true);

      await controller.hapusUser(id);

      _showSnackBar("Pengguna dihapus", Colors.orange);
    } catch (e) {
      _showSnackBar("Gagal menghapus", Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- UI UTAMA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
<<<<<<< HEAD
        backgroundColor: const Color(0xFF0061CD),
        onPressed: () => _dialogForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                          Text(
                            'Pengguna',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola dan pantau data pengguna laboratorium',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildSearchRow(),

                  Expanded(child: _buildUserList()),
                ],
              ),
      ),
    );
  }
=======
        backgroundColor: primaryBlue,
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          /* HEADER */
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 14,
            ),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pengguna",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kelola data pengguna laboratorium",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Cari pengguna...",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filterStatus,
                        items:
                            const ["Semua", "Aktif", "Nonaktif"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => filterStatus = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text(
            "${pengguna.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("Total Pengguna", style: TextStyle(fontSize: 12)),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = list[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(p.email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(p.status),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => openForm(data: p),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => hapusPengguna(p),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* =======================
   FORM TAMBAH / EDIT
======================= */
class _FormPengguna extends StatefulWidget {
  final String title;
  final PenggunaModel? initial;
  final Color primaryBlue;

  const _FormPengguna({
    required this.title,
    required this.initial,
    required this.primaryBlue,
  });

  @override
  State<_FormPengguna> createState() => _FormPenggunaState();
}

class _FormPenggunaState extends State<_FormPengguna> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;
  String status = "Aktif";

  @override
  void initState() {
    super.initState();
    namaCtrl = TextEditingController(text: widget.initial?.nama ?? "");
    emailCtrl = TextEditingController(text: widget.initial?.email ?? "");
    passwordCtrl = TextEditingController();
    status = widget.initial?.status ?? "Aktif";
  }

  InputDecoration field(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFE8F1FF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
>>>>>>> 8a311b07cca40b07a2bd8166f3ac8ad1395e49c6

  Widget _buildSearchRow() {
    return Padding(
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Cari nama...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterRole,
                items: ["Semua", "Admin", "Petugas", "Peminjam"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _filterRole = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _streamUsers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final list = snapshot.data!.where((u) {
          final matchesName = u['nama']
              .toString()
              .toLowerCase()
              .contains(_searchCtrl.text.toLowerCase());

          final matchesRole = _filterRole == "Semua" ||
              u['role'].toString().toLowerCase() == _filterRole.toLowerCase();

          return matchesName && matchesRole;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, i) => _cardUser(list[i]),
        );
      },
    );
  }

  Widget _cardUser(Map<String, dynamic> user) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F0FE),
          child: Icon(Icons.person, color: Color(0xFF0061CD)),
        ),
        title: Text(user['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? '-', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              user['role'].toString().toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF0061CD),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => _dialogForm(user: user),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(user['id_user']),
            ),
          ],
=======
      padding: EdgeInsets.only(bottom: bottom, left: 14, right: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                const Text("Nama Lengkap", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: namaCtrl,
                  decoration: field("Masukkan nama lengkap"),
                  validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 12),

                const Text("Email", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: emailCtrl,
                  decoration: field("Masukkan email"),
                  validator:
                      (v) => !v!.contains("@") ? "Email tidak valid" : null,
                ),
                const SizedBox(height: 12),

                if (widget.initial == null) ...[
                  const Text("Kata Sandi", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: field("Masukkan kata sandi"),
                    validator:
                        (v) => v!.isEmpty ? "Password wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),
                ],

                const Text("Status", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField(
                  value: status,
                  decoration: field("Pilih status"),
                  items:
                      const ["Aktif", "Nonaktif"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => status = v!),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryBlue,
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          Navigator.pop(
                            context,
                            PenggunaModel(
                              id:
                                  widget.initial?.id ??
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              nama: namaCtrl.text,
                              email: emailCtrl.text,
                              role: "Petugas",
                              status: status,
                            ),
                          );
                        },
                        child: Text(
                          widget.initial == null ? "Tambah" : "Simpan",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
>>>>>>> 8a311b07cca40b07a2bd8166f3ac8ad1395e49c6
        ),
      ),
    );
  }

  // --- DIALOG FORM (CREATE & EDIT) ---

  void _dialogForm({Map<String, dynamic>? user}) {
    final nameC = TextEditingController(text: user?['nama']);
    final emailC = TextEditingController(text: user?['email']);
    final passC = TextEditingController();

    final roles = ["Admin", "Petugas", "Peminjam"];
    String currentRole = roles.firstWhere(
      (e) => e.toLowerCase() == (user?['role']?.toString().toLowerCase() ?? "petugas"),
      orElse: () => "Petugas",
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(user == null ? "Tambah Pengguna" : "Edit Pengguna"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(nameC, "Nama Lengkap"),
                _textField(emailC, "Email", enabled: user == null),
                _textField(
                  passC,
                  "Kata Sandi",
                  obscure: true,
                  hint: user != null ? "Kosongkan jika tak diubah" : null,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: currentRole,
                      items: roles
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => currentRole = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0061CD)),
              onPressed: () {
                if (user == null) {
                  _tambahUser(emailC.text, passC.text, nameC.text, currentRole);
                } else {
                  _updateUser(user['id_user'], nameC.text, currentRole, passC.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String label, {
    bool obscure = false,
    bool enabled = true,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF3F7FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus?"),
        content: const Text("Data tidak bisa dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              _hapusUser(id);
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
