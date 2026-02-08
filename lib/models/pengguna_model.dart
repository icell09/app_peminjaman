import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaAdmin extends StatefulWidget {
  const PenggunaAdmin({super.key});

  @override
  State<PenggunaAdmin> createState() => _PenggunaAdminState();
}

class _PenggunaAdminState extends State<PenggunaAdmin> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = "Semua";

  // --- LOGIKA DATA ---

  // Mengambil data secara Realtime (Stream)
  Stream<List<Map<String, dynamic>>> get _userStream {
    return supabase
        .from('users')
        .stream(primaryKey: ['id_user'])
        .order('nama', ascending: true);
  }

  // Tambah User (Lewat Auth, Trigger otomatis isi tabel users)
  Future<void> _handleSignUp(String email, String password, String nama, String role) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nama': nama, // Data ini dikirim ke Trigger SQL
          'role': role,
        },
      );
      if (mounted) _showToast("User berhasil didaftarkan!", Colors.green);
    } catch (e) {
      _showToast("Gagal: $e", Colors.red);
    }
  }

  // Update User (Hanya Nama dan Role)
  Future<void> _handleUpdate(String id, String nama, String role) async {
    try {
      await supabase.from('users').update({
        'nama': nama,
        'role': role,
      }).match({'id_user': id});
      if (mounted) _showToast("Data diperbarui", Colors.blue);
    } catch (e) {
      _showToast("Gagal update: $e", Colors.red);
    }
  }

  // Hapus User
  Future<void> _handleDelete(String id) async {
    try {
      await supabase.from('users').delete().match({'id_user': id});
      if (mounted) _showToast("User dihapus", Colors.orange);
    } catch (e) {
      _showToast("Gagal hapus: $e", Colors.red);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // --- TAMPILAN UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Manajemen Pengguna", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Data kosong"));

                final filteredList = snapshot.data!.where((user) {
                  final matchesSearch = user['nama'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
                  final matchesRole = _selectedRole == "Semua" || user['role'] == _selectedRole;
                  return matchesSearch && matchesRole;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => _buildUserCard(filteredList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Cari nama...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _selectedRole,
            items: ["Semua", "Admin", "Petugas", "Peminjam"].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
            onChanged: (val) => setState(() => _selectedRole = val!),
          )
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(user['nama'][0].toUpperCase())),
        title: Text(user['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${user['email']}\nRole: ${user['role']}"),
        trailing: Wrap(
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showUserForm(user: user)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _handleDelete(user['id_user'])),
          ],
        ),
      ),
    );
  }

  void _showUserForm({Map<String, dynamic>? user}) {
    final nameC = TextEditingController(text: user?['nama'] ?? '');
    final emailC = TextEditingController(text: user?['email'] ?? '');
    final passC = TextEditingController();
    String roleC = user?['role'] ?? 'Peminjam';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user == null ? "Tambah Pengguna" : "Edit Pengguna", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nama Lengkap")),
            if (user == null) ...[
              TextField(controller: emailC, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: passC, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            ],
            DropdownButtonFormField<String>(
              value: roleC,
              items: ["Admin", "Petugas", "Peminjam"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => roleC = v!,
              decoration: const InputDecoration(labelText: "Role"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (user == null) {
                  _handleSignUp(emailC.text, passC.text, nameC.text, roleC);
                } else {
                  _handleUpdate(user['id_user'], nameC.text, roleC);
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