class LogAktivitas {
  final String aktivitas;
  final String info;
  final DateTime tanggal;

  LogAktivitas({
    required this.aktivitas,
    required this.info,
    required this.tanggal,
  });

  factory LogAktivitas.fromMap(Map<String, dynamic> map) {
    return LogAktivitas(
      aktivitas: map['aktivitas'] ?? 'Tidak diketahui',
      info: map['info'] ?? '-',
      tanggal:
          map['tanggal'] != null
              ? DateTime.parse(map['tanggal'])
              : DateTime.now(),
    );
  }
}
