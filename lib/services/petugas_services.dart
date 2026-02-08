import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class PetugasController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil data user yang sedang login dari Supabase
  UserModel getLoggedInUser() {
    final user = _supabase.auth.currentUser;
    // userMetadata mengambil data tambahan (seperti nama & role) yang disimpan saat registrasi
    final metadata = user?.userMetadata;

    return UserModel(
      nama: metadata?['nama'] ?? "Nama Tidak Tersedia", 
      email: user?.email ?? "Email Tidak Tersedia",
      password: "", 
      status: metadata?['role'] ?? "Petugas", 
    );
  }

  /// Proses Logout: Menghapus session di Supabase dan kembali ke Login
  Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      if (context.mounted) {
        // Menghapus semua tumpukan halaman agar user tidak bisa klik 'Back' ke profil
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Logout: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}

  // --- LOGIKA HITUNG DENDA ---
  Map<String, dynamic> hitungDenda(DateTime tenggat, DateTime? kembali) {
    if (kembali == null) return {"isTerlambat": false, "selisih": 0, "denda": 0};
    
    DateTime t1 = DateTime(tenggat.year, tenggat.month, tenggat.day);
    DateTime t2 = DateTime(kembali.year, kembali.month, kembali.day);

    if (t2.isAfter(t1)) {
      int selisih = t2.difference(t1).inDays;
      return {"isTerlambat": true, "selisih": selisih, "denda": selisih * 5000};
    }
    return {"isTerlambat": false, "selisih": 0, "denda": 0};
  }
