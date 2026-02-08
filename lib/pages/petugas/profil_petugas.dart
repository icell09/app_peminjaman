import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/petugas_services.dart'; 
import '../../models/user_model.dart';

class ProfilPetugas extends StatefulWidget {
  const ProfilPetugas({super.key});

  @override
  State<ProfilPetugas> createState() => _ProfilPetugasState();
}

class _ProfilPetugasState extends State<ProfilPetugas> {
  final _controller = PetugasController();
  
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _sandiController;
  String selectedStatus = "Petugas";

  @override
  void initState() {
    super.initState();
    // Sinkronisasi data awal dengan database
    final user = _controller.getLoggedInUser();
    
    _namaController = TextEditingController(text: user.nama);
    _emailController = TextEditingController(text: user.email);
    _sandiController = TextEditingController(text: "**********");
    
    // Pastikan status dari DB ada di list dropdown
    selectedStatus = (user.status == "Admin" || user.status == "Petugas") 
        ? user.status 
        : "Petugas";
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Keluar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text("Apakah anda yakin ingin keluar dari akun ?"),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _controller.logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0061D1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Keluar", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const CircleAvatar(
                    radius: 65,
                    backgroundColor: Color(0xFF0061D1),
                    child: Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  _buildField("Nama", _namaController),
                  _buildField("Email", _emailController),
                  _buildField("Kata Sandi", _sandiController, isPass: true),
                  _buildDropdownStatus(), // Dropdown Status Baru
                  const SizedBox(height: 50),
                  _buildLogoutButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.only(top: 60, bottom: 30, left: 25),
    decoration: const BoxDecoration(
      color: Color(0xFF0061D1),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Profil", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text("Kelola akun pada aplikasi", style: TextStyle(color: Colors.white70)),
      ],
    ),
  );

  Widget _buildField(String label, TextEditingController controller, {bool isPass = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPass,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE3F2FD),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: isPass ? const Icon(Icons.visibility_off_outlined) : null,
          ),
        ),
      ],
    ),
  );

  Widget _buildDropdownStatus() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Status", style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedStatus,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0061D1)),
            items: ["Petugas", "Admin"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => selectedStatus = v!),
          ),
        ),
      ),
    ],
  );

  Widget _buildLogoutButton() => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton.icon(
      onPressed: _showLogoutDialog,
      icon: const Icon(Icons.logout),
      label: const Text("Keluar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0061D1), 
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
      ),
    ),
  );
}