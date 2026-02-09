import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> login(String email, String password) async {
    try {
      // Cek dulu apakah email ada di tabel 'users'
      final checkUser = await _supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      print("DATA DARI DATABASE: $checkUser"); // Lihat hasilnya di Debug Console VS Code

      if (checkUser == null) {
        return "email_not_found"; // Tandai jika email tidak ada
      }

      // Jika email ada, coba login (verifikasi password)
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return null; // Sukses
    } on AuthException catch (e) {
      if (e.message.contains("Invalid login credentials")) {
        return "password_wrong"; // Tandai jika password salah
      }
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan sistem";
    }
  }
}