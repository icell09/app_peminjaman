import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/peminjam_service.dart';

class FormPeminjaman extends StatefulWidget {
  final List<Map<String, dynamic>> alatDipilih;

  const FormPeminjaman({super.key, required this.alatDipilih});

  @override
  State<FormPeminjaman> createState() => _FormPeminjamanState();
}

class _FormPeminjamanState extends State<FormPeminjaman> {
  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;
  TimeOfDay? _waktuPinjam;
  TimeOfDay? _waktuKembali;

  late List<Map<String, dynamic>> _alatList;

  @override
  void initState() {
    super.initState();
    // pakai qty dari keranjang asli
    _alatList = widget.alatDipilih.map((a) => {...a}).toList();
  }

  // ===== Helpers =====
  String _fmtDate(DateTime? d) {
    if (d == null) return 'Pilih tanggal';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _fmtTime(TimeOfDay? t) {
    if (t == null) return 'Waktu';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatTimeForDb(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool get _valid =>
      _alatList.isNotEmpty &&
      _tanggalPinjam != null &&
      _waktuPinjam != null &&
      _tanggalKembali != null &&
      _waktuKembali != null;

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
    ],
  );

  // ===== Qty/Delete =====
  void _ubahJumlah(int index, int delta) {
    setState(() {
      final current = (_alatList[index]['qty'] ?? 1) as int;
      final next = current + delta;
      if (next >= 1) _alatList[index]['qty'] = next;
    });
  }

  void _hapusAlat(int index) {
    setState(() => _alatList.removeAt(index));
  }

  // ===== Pickers =====
  Future<void> _pickTanggalPinjam() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _tanggalPinjam ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        _tanggalPinjam = date;
        if (_tanggalKembali != null && _tanggalKembali!.isBefore(date)) {
          _tanggalKembali = null;
          _waktuKembali = null;
        }
      });
    }
  }

  Future<void> _pickTanggalKembali() async {
    final now = DateTime.now();
    final min = _tanggalPinjam ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: _tanggalKembali ?? min,
      firstDate: min,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) setState(() => _tanggalKembali = date);
  }

  Future<void> _pickWaktuPinjam() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _waktuPinjam ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _waktuPinjam = picked);
  }

  Future<void> _pickWaktuKembali() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _waktuKembali ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _waktuKembali = picked);
  }

  // ===== Tombol simpel: balik ke beranda untuk tambah alat =====
  void _kembaliUntukTambahAlat() {
    Navigator.pop(context, {'items': _alatList, 'submitted': false});
  }

  // ===== Submit =====
  void _ajukan() async {
    if (!_valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi alat dan tanggal dulu')),
      );
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw 'User belum login';
      }

      final service = PeminjamanService();

      await service.ajukanPeminjaman(
        idUser: user.id,
        tglPinjam: _tanggalPinjam!,
        tglKembaliRencana: _tanggalKembali!,
        alat: _alatList,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peminjaman berhasil diajukan')),
      );

      Navigator.pop(context, {'items': _alatList, 'submitted': true});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengajukan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // list alat
                    if (_alatList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: const Text('Tidak ada alat dipilih'),
                      )
                    else
                      Column(
                        children: List.generate(_alatList.length, (i) {
                          final alat = _alatList[i];
                          final qty = (alat['qty'] ?? 1) as int;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: _cardDecoration(),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    alat['gambar'],
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          width: 62,
                                          height: 62,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    alat['nama_alat']?.toString() ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _qtyBox(
                                  qty: qty,
                                  onMinus: () => _ubahJumlah(i, -1),
                                  onPlus: () => _ubahJumlah(i, 1),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _hapusAlat(i),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                    const SizedBox(height: 8),

                    // tombol tambah alat (simpel: balik ke beranda)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B63CE),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _kembaliUntukTambahAlat,
                        child: const Text(
                          'Tambahkan alat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Peminjaman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _pillField(
                            text: _fmtDate(_tanggalPinjam),
                            icon: Icons.calendar_month,
                            onTap: _pickTanggalPinjam,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _pillField(
                            text: _fmtTime(_waktuPinjam),
                            icon: Icons.access_time,
                            onTap: _pickWaktuPinjam,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Pengembalian',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _pillField(
                            text: _fmtDate(_tanggalKembali),
                            icon: Icons.calendar_month,
                            onTap: _pickTanggalKembali,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _pillField(
                            text: _fmtTime(_waktuKembali),
                            icon: Icons.access_time,
                            onTap: _pickWaktuKembali,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B63CE),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _ajukan,
                        child: const Text(
                          'Ajukan Peminjaman',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== UI Widgets =====
  Widget _topHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B63CE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _kembaliUntukTambahAlat,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Pengajuan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.notifications_none, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBox({
    required int qty,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.remove, size: 16),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 26,
            child: Text(
              '$qty',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: onPlus,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color:
                      (text == 'Pilih tanggal' || text == 'Waktu')
                          ? Colors.black54
                          : Colors.black87,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 18, color: const Color(0xFF0B63CE)),
          ],
        ),
      ),
    );
  }
}
