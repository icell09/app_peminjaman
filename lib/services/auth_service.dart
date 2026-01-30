import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> login(String email, String password) async {
    try {
      // 1. Cek dulu apakah email ada di tabel 'users'
      final checkUser = await _supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (checkUser == null) {
        return "email_not_found"; // Tandai jika email tidak ada
      }

      // 2. Jika email ada, coba login (verifikasi password)
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