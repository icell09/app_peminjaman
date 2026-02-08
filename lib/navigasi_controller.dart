import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import file Admin
import 'pages/admin/beranda_admin.dart';
import 'pages/admin/alat_admin.dart';
import 'pages/admin/pengguna_admin.dart';
import 'pages/admin/aktivitas_admin.dart';
import 'pages/admin/profil_admin.dart';

// Import file Petugas
import 'pages/petugas/beranda_petugas.dart';
import 'pages/petugas/persetujuan_petugas.dart';
import 'pages/petugas/laporan_petugas.dart';
import 'pages/petugas/pengembalian_petugas.dart';
import 'pages/petugas/profil_petugas.dart';

// Import file Peminjam
import 'pages/peminjam/beranda_peminjam.dart';
import 'pages/peminjam/pinjaman_peminjam.dart';
import 'pages/peminjam/profil_peminjam.dart';

enum Role { admin, petugas, peminjam }

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  // Ubah menjadi variabel dinamis, default peminjam
  Role _currentRole = Role.peminjam; 
  int _selectedIndex = 0;
  bool _isLoading = true; // Tambahkan loading state

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id_user', user.id)
          .maybeSingle(); // Menggunakan maybeSingle agar tidak error jika data kosong

      if (data != null && data['role'] != null) {
        String roleFromDb = data['role'].toString().toLowerCase(); // Paksa ke huruf kecil

        setState(() {
          if (roleFromDb == 'admin') {
            _currentRole = Role.admin;
          } else if (roleFromDb == 'petugas') {
            _currentRole = Role.petugas;
          } else {
            _currentRole = Role.peminjam;
          }
          _isLoading = false;
        });
      } else {
        // Jika data di tabel users tidak ditemukan sama sekali
        print("Data user tidak ditemukan di tabel public.users");
        setState(() => _isLoading = false);
      }
    }
  } catch (e) {
    print("Error detail: $e");
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading saat sedang mengecek role
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Widget> screens = [];
    List<BottomNavigationBarItem> navItems = [];

    // Gunakan _currentRole yang sudah diupdate dari Database
    if (_currentRole == Role.admin) {
      screens = [const BerandaAdmin(), const AlatAdmin(), const PenggunaAdmin(), const AktivitasAdmin(),  ProfilAdmin()];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), label: 'Alat'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Pengguna'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Aktivitas'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ];
    } else if (_currentRole == Role.petugas) {
      screens = [const BerandaPetugas(), const PersetujuanPetugas(), const LaporanPetugas(), const PengembalianPetugas(), const ProfilPetugas()];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_outlined), label: 'Persetujuan'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Laporan'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_return_outlined), label: 'Pengembalian'),  
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),  
      ];
    } else {
      screens = [const BerandaPeminjam(), const PinjamanPeminjam(), const ProfilPeminjam()];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'Pinjaman'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ];
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        color: const Color(0xFF0056C1),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          items: navItems,
        ),
      ),
    );
  }
}