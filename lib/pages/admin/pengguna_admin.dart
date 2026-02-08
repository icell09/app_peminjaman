import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanManajemenPengguna extends StatefulWidget {
  const HalamanManajemenPengguna({super.key});

  @override
  State<HalamanManajemenPengguna> createState() => _HalamanManajemenPenggunaState();
}

class _HalamanManajemenPenggunaState extends State<HalamanManajemenPengguna> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterRole = "Semua";

  // --- 1. READ: Ambil data secara Realtime ---
  Stream<List<Map<String, dynamic>>> get _streamUsers {
    return supabase
        .from('users')
        .stream(primaryKey: ['id_user'])
        .order('nama', ascending: true);
  }

  // --- 2. CREATE: Tambah User ---
  Future<void> _tambahUser(String email, String password, String nama, String role) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nama': nama, 'role': role},
      );
      if (mounted) _showSnackBar("User berhasil ditambahkan", Colors.green);
    } catch (e) {
      if (mounted) _showSnackBar("Gagal menambah: $e", Colors.red);
    }
  }

  // --- 3. UPDATE: Ubah data di tabel public.users ---
  Future<void> _updateUser(String id, String nama, String role) async {
    try {
      await supabase.from('users').update({
        'nama': nama,
        'role': role,
      }).match({'id_user': id});
      
      if (mounted) _showSnackBar("Data $nama berhasil diperbarui", Colors.blue);
    } catch (e) {
      if (mounted) _showSnackBar("Gagal update: $e", Colors.red);
    }
  }

  // --- 4. DELETE: Hapus data (Memicu Trigger di Database) ---
  Future<void> _hapusUser(String id, String nama) async {
    try {
      // Menghapus di public.users akan otomatis menghapus di Auth (jika Trigger SQL sudah dipasang)
      await supabase.from('users').delete().match({'id_user': id});
      if (mounted) _showSnackBar("User $nama berhasil dihapus", Colors.orange);
    } catch (e) {
      if (mounted) _showSnackBar("Gagal menghapus: $e", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0061D7),
        onPressed: () => _dialogForm(), 
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          _buildBlueHeader(),
          SafeArea(
            child: Column(
              children: [
                _buildHeaderTitle(),
                _buildSearchAndFilterRow(),
                Expanded(child: _buildUserList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildBlueHeader() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF0061D7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Manajemen Pengguna", 
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Cari nama...", 
                  border: InputBorder.none, 
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterRole,
                  isExpanded: true,
                  items: ["Semua", "Admin", "Petugas", "Peminjam"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _filterRole = v!),
                ),
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final list = snapshot.data!.where((u) {
          final matchesName = u['nama'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
          final matchesRole = _filterRole == "Semua" || u['role'] == _filterRole;
          return matchesName && matchesRole;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (context, i) => _cardUser(list[i]),
        );
      },
    );
  }

  Widget _cardUser(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF2FF), 
                child: Icon(Icons.person, color: Color(0xFF0061D7)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(user['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user['email'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                user['role'], 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 11),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _dialogForm(user: user), 
                icon: const Icon(Icons.edit, size: 18), 
                label: const Text("Edit"),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () => _confirmDelete(user['id_user'], user['nama']), 
                icon: const Icon(Icons.delete, size: 18, color: Colors.red), 
                label: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _confirmDelete(String id, String nama) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pengguna?"),
        content: Text("Yakin ingin menghapus $nama? Akun login juga akan terhapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              _hapusUser(id, nama);
              Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _dialogForm({Map<String, dynamic>? user}) {
    final nameC = TextEditingController(text: user?['nama']);
    final emailC = TextEditingController(text: user?['email']);
    final passC = TextEditingController();
    String roleC = user?['role'] ?? 'Peminjam';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(user == null ? "Tambah Pengguna" : "Edit Pengguna"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nama")),
                if (user == null) ...[
                  TextField(controller: emailC, decoration: const InputDecoration(labelText: "Email")),
                  TextField(controller: passC, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                ],
                DropdownButtonFormField<String>(
                  value: roleC,
                  items: ["Admin", "Petugas", "Peminjam"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => roleC = v!),
                  decoration: const InputDecoration(labelText: "Role"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                if (user == null) {
                  _tambahUser(emailC.text, passC.text, nameC.text, roleC);
                } else {
                  _updateUser(user['id_user'], nameC.text, roleC);
                }
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}