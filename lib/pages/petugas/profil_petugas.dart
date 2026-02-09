import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/login.dart'; // sesuaikan path login Anda

class ProfilPetugas extends StatefulWidget {
  const ProfilPetugas({super.key});

  @override
  State<ProfilPetugas> createState() => _ProfilPetugasState();
}

class _ProfilPetugasState extends State<ProfilPetugas> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Controller untuk menampilkan data
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  final TextEditingController _passController =
      TextEditingController(text: "********");

  @override
  void initState() {
    super.initState();

    final user = supabase.auth.currentUser;

    // Ambil data user dari Supabase session
    _namaController = TextEditingController(
      text: user?.userMetadata?['nama'] ?? "Petugas",
    );
    _emailController = TextEditingController(
      text: user?.email ?? "",
    );
  }

  // ============================================================
  // ========================= LOGOUT ===========================
  // ============================================================

  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saat logout: $e")),
        );
      }
    }
  }

  // ============================================================
  // ================== DIALOG KONFIRMASI =======================
  // ============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah anda yakin ingin keluar dari akun?"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056C1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                  child: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ============================ UI ============================
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== Header Biru =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 25, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0056C1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profil",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Kelola akun pada aplikasi",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Avatar =====
                  const Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFF0056C1),
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ===== Fields =====
                  _buildLabel("Nama"),
                  _buildTextField(_namaController),

                  _buildLabel("Email"),
                  _buildTextField(_emailController),

                  _buildLabel("Kata Sandi"),
                  _buildTextField(_passController, isPassword: true),

                  _buildLabel("Status"),
                  _buildDropdown(),

                  const SizedBox(height: 40),

                  // ===== Tombol Logout =====
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Keluar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056C1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
    );
  }

  // ============================================================
  // ======================== HELPERS ===========================
  // ============================================================

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 15),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildTextField(
    TextEditingController controller, {
    bool isPassword = false,
  }) =>
      TextField(
        controller: controller,
        obscureText: isPassword,
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF0F5FA),
          suffixIcon: isPassword
              ? const Icon(Icons.visibility_off_outlined)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _buildDropdown() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: "Petugas",
          isExpanded: true,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: "Petugas", child: Text("Petugas")),
          ],
          onChanged: (v) {},
        ),
      );
}
