import 'package:flutter/material.dart';
import 'package:ukk_peminjaman/services/alat_service.dart';

class PinjamanPeminjam extends StatefulWidget {
  const PinjamanPeminjam({super.key});

  @override
  State<PinjamanPeminjam> createState() => _PinjamanPeminjamState();
}

class _PinjamanPeminjamState extends State<PinjamanPeminjam> {
  late Future<List<Map<String, dynamic>>> futurePinjaman;
  late AlatSupabaseService _alatService;

  @override
  void initState() {
    super.initState();
    _alatService = AlatSupabaseService();
    futurePinjaman = _alatService.fetchPinjamanSaya();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinjaman Saya')),
      body: FutureBuilder(
        future: futurePinjaman,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada pinjaman'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];
              final alat = item['alat'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    alat['gambar'],
                    width: 50,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  ),
                  title: Text(alat['nama_alat']),
                  subtitle: Text('Status: ${item['status']}'),
                  trailing:
                      item['status'] == 'dipinjam'
                          ? ElevatedButton(
                            onPressed: () async {
                              await _alatService.kembalikanAlat(
                                idPeminjaman: item['id_peminjaman'],
                                idAlat: alat['id_alat'],
                                stokSekarang: alat['stok'],
                              );

                              setState(() {
                                futurePinjaman =
                                    _alatService.fetchPinjamanSaya();
                              });
                            },
                            child: const Text('Kembalikan'),
                          )
                          : const Icon(Icons.check, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
