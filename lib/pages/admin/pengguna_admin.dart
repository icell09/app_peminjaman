import 'package:flutter/material.dart';

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
class PenggunaAdmin extends StatefulWidget {
  const PenggunaAdmin({super.key});

  @override
  State<PenggunaAdmin> createState() => _PenggunaAdminState();
}

class _PenggunaAdminState extends State<PenggunaAdmin> {
  final TextEditingController searchCtrl = TextEditingController();
  String filterStatus = "Semua";

  final Color primaryBlue = const Color(0xFF0B5ED7);

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
      final matchSearch =
          q.isEmpty || p.nama.toLowerCase().contains(q) || p.email.toLowerCase().contains(q);
      final matchStatus = filterStatus == "Semua" || p.status == filterStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  /* =======================
     FORM TAMBAH / EDIT
  ======================= */
  Future<void> openForm({PenggunaModel? data}) async {
    final result = await showModalBottomSheet<PenggunaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormPengguna(
        title: data == null ? "Tambah Pengguna" : "Edit Pengguna",
        initial: data,
        primaryBlue: primaryBlue,
      ),
    );

    if (result == null) return;

    setState(() {
      final index = pengguna.indexWhere((e) => e.id == result.id);
      if (index >= 0) {
        pengguna[index] = result;
        showSnack("Pengguna berhasil diperbarui");
      } else {
        pengguna.insert(0, result);
        showSnack("Pengguna berhasil ditambahkan");
      }
    });
  }

  /* =======================
     HAPUS
  ======================= */
  Future<void> hapusPengguna(PenggunaModel data) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Pengguna"),
        content: const Text("Apakah anda yakin ingin menghapus pengguna ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => pengguna.removeWhere((e) => e.id == data.id));
    showSnack("Pengguna berhasil dihapus");
  }

  /* =======================
     UI
  ======================= */
  @override
  Widget build(BuildContext context) {
    final list = filteredPengguna;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: ""),
        ],
      ),

      body: Column(
        children: [
          /* HEADER */
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 14,
            ),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pengguna",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Kelola data pengguna laboratorium",
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Cari pengguna...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filterStatus,
                        items: const ["Semua", "Aktif", "Nonaktif"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => filterStatus = v!),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Text("${pengguna.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text("Total Pengguna", style: TextStyle(fontSize: 12)),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CardPengguna(
                data: list[i],
                primaryBlue: primaryBlue,
                onEdit: () => openForm(data: list[i]),
                onDelete: () => hapusPengguna(list[i]),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/* =======================
   CARD
======================= */
class _CardPengguna extends StatelessWidget {
  final PenggunaModel data;
  final Color primaryBlue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardPengguna({
    required this.data,
    required this.primaryBlue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEAF2FF),
                child: Icon(Icons.person_outline, color: primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(data.email, style: const TextStyle(fontSize: 12)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 18),
                  label: Text("Hapus", style: TextStyle(color: Colors.red.shade600)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/* =======================
   FORM
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

  String role = "Petugas";
  String status = "Aktif";

  @override
  void initState() {
    super.initState();
    namaCtrl = TextEditingController(text: widget.initial?.nama ?? "");
    emailCtrl = TextEditingController(text: widget.initial?.email ?? "");
    role = widget.initial?.role ?? "Petugas";
    status = widget.initial?.status ?? "Aktif";
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            TextFormField(
              controller: namaCtrl,
              validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailCtrl,
              validator: (v) => !v!.contains("@") ? "Email tidak valid" : null,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: status,
                    items: const ["Aktif", "Nonaktif"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => status = v!),
                    decoration: const InputDecoration(labelText: "Status"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField(
                    value: role,
                    items: const ["Admin", "Petugas"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => role = v!),
                    decoration: const InputDecoration(labelText: "Role"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: widget.primaryBlue),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      Navigator.pop(
                        context,
                        PenggunaModel(
                          id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          nama: namaCtrl.text,
                          email: emailCtrl.text,
                          role: role,
                          status: status,
                        ),
                      );
                    },
                    child: const Text("Simpan"),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
