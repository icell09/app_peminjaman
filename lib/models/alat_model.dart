class Alat {
  final String id;
  final String nama;
  final int stok;
  final String kategori;
  final String? imageUrl;

  Alat({required this.id, required this.nama, required this.stok, required this.kategori, this.imageUrl});
}