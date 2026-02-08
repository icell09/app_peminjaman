import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isObscured = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  void _handleLogin() async {
  setState(() {
    // Reset error lama dan validasi kolom kosong
    _emailError = _emailController.text.isEmpty ? "Alamat email tidak boleh kosong" : null;
    _passwordError = _passwordController.text.isEmpty ? "Kata sandi tidak boleh kosong" : null;
  });

  if (_emailError == null && _passwordError == null) {
    setState(() => _isLoading = true);
    
    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        
        if (result == "email_not_found") {
          // Hanya kolom email yang merah
          _emailError = "Email tidak terdaftar";
          _passwordError = null;
        } 
        else if (result == "password_wrong") {
          // Hanya kolom kata sandi yang merah
          _emailError = null;
          _passwordError = "kata sandi salah";
        } 
        else if (result != null) {
          // Error lainnya (jaringan, dsb)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result), backgroundColor: Colors.red),
          );
        } 
        else {
          // Sukses Login
          Navigator.pushReplacementNamed(context, '/main');
        }
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('LabifyBr', 
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              ),
              const SizedBox(height: 50),
              
              // --- INPUT EMAIL ---
              const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                onChanged: (v) => setState(() => _emailError = null), // Hapus error saat mengetik
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat email',
                  errorText: _emailError, // PESAN VALIDASI TAMPIL DI SINI
                  filled: true,
                  fillColor: const Color(0xFFE3F2FD),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  errorStyle: const TextStyle(color: Colors.red), // Gaya teks error
                ),
              ),
              
              const SizedBox(height: 20),
              
              // --- INPUT KATA SANDI ---
              const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isObscured,
                onChanged: (v) => setState(() => _passwordError = null), // Hapus error saat mengetik
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  errorText: _passwordError, // PESAN VALIDASI TAMPIL DI SINI
                  filled: true,
                  fillColor: const Color(0xFFE3F2FD),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  errorStyle: const TextStyle(color: Colors.red),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // --- TOMBOL LOGIN ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Masuk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}