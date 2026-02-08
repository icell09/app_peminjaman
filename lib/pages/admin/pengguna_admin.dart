import 'package:flutter/material.dart';
import 'package:ukk_peminjaman/services/pengguna_services.dart';
import '../../services/pengguna_services.dart';

class PenggunaAdmin extends StatefulWidget {
  const PenggunaAdmin({super.key});

  @override
  State<PenggunaAdmin> createState() => _PenggunaAdminState();
}

class _PenggunaAdminState extends State<PenggunaAdmin> {
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

      await controller.updateUser(
        id: id,
        nama: nama,
        role: role,
        password: password.isEmpty ? null : password,
      );

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

  Widget _buildSearchRow() {
    return Padding(
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
