class Pinjaman {
  final int idPeminjaman;
  final String namaAlat;
  final String status;
  final String gambar;
  final String tanggalPinjam;
  final int idAlat;
  final int stok;

  Pinjaman({
    required this.idPeminjaman,
    required this.namaAlat,
    required this.status,
    required this.gambar,
    required this.tanggalPinjam,
    required this.idAlat,
    required this.stok,
  });

  factory Pinjaman.fromJson(Map<String, dynamic> json) {
    return Pinjaman(
      idPeminjaman: json['id_peminjaman'],
      status: json['status'],
      tanggalPinjam: json['tanggal_pinjam'],
      namaAlat: json['alat']['nama_alat'],
      gambar: json['alat']['gambar'],
      idAlat: json['alat']['id_alat'],
      stok: json['alat']['stok'],
    );
  }
}
