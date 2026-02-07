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

    if (result == null) return;

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
    }
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

    return Padding(
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
        ),
      ),
    );
  }
}
