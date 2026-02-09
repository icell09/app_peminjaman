import 'package:flutter/material.dart';

class FormPeminjaman extends StatefulWidget {
  final List<Map<String, dynamic>> alatDipilih;

  const FormPeminjaman({super.key, required this.alatDipilih});

  @override
  State<FormPeminjaman> createState() => _FormPeminjamanState();
}

class _FormPeminjamanState extends State<FormPeminjaman> {
  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;

  late List<Map<String, dynamic>> _alatList; // untuk modifikasi jumlah alat

  @override
  void initState() {
    super.initState();
    // Salin dari widget dan tambahkan field 'qty' default 1
    _alatList =
        widget.alatDipilih.map((a) {
          return {...a, 'qty': 1};
        }).toList();
  }

  Future<void> _pickTanggalPinjam() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        _tanggalPinjam = date;
      });
    }
  }

  Future<void> _pickTanggalKembali() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _tanggalPinjam ?? now,
      firstDate: _tanggalPinjam ?? now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        _tanggalKembali = date;
      });
    }
  }

  void _ajukanPeminjaman() {
    if (_tanggalPinjam == null || _tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal pinjam dan pengembalian')),
      );
      return;
    }

    // Logic kirim ke database / API
    print('Alat dipinjam: $_alatList');
    print('Tanggal pinjam: $_tanggalPinjam');
    print('Tanggal kembali: $_tanggalKembali');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peminjaman berhasil diajukan!')),
    );

    Navigator.pop(context);
  }

  void _hapusAlat(int index) {
    setState(() {
      _alatList.removeAt(index);
    });
  }

  void _ubahJumlah(int index, int delta) {
    setState(() {
      final newQty = _alatList[index]['qty'] + delta;
      if (newQty >= 1) {
        _alatList[index]['qty'] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Peminjaman')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alat yang dipilih:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _alatList.isEmpty
                      ? const Center(child: Text('Tidak ada alat dipilih'))
                      : ListView.builder(
                        itemCount: _alatList.length,
                        itemBuilder: (context, index) {
                          final alat = _alatList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  alat['gambar'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(alat['nama_alat']),
                              subtitle: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => _ubahJumlah(index, -1),
                                  ),
                                  Text('${alat['qty']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _ubahJumlah(index, 1),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _hapusAlat(index),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: _pickTanggalPinjam,
              decoration: InputDecoration(
                labelText: 'Tanggal Pinjam',
                suffixIcon: const Icon(Icons.calendar_month),
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text:
                    _tanggalPinjam != null
                        ? '${_tanggalPinjam!.day}/${_tanggalPinjam!.month}/${_tanggalPinjam!.year}'
                        : '',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: _pickTanggalKembali,
              decoration: InputDecoration(
                labelText: 'Tanggal Pengembalian',
                suffixIcon: const Icon(Icons.calendar_month),
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text:
                    _tanggalKembali != null
                        ? '${_tanggalKembali!.day}/${_tanggalKembali!.month}/${_tanggalKembali!.year}'
                        : '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0061CD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _ajukanPeminjaman,
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
    );
  }
}
