import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaController {
  final SupabaseClient supabase;

  PenggunaController({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> streamUsers() {
    return supabase
        .from('users')
        .stream(primaryKey: ['id_user'])
        .order('nama', ascending: true);
  }

  Future<void> updateUser({
    required String id,
    required String nama,
    required String role,
    String? password, // (belum dipakai, lihat catatan di bawah)
  }) async {
    await supabase.from('users').update({
      'nama': nama,
      'role': role,
    }).match({'id_user': id});
  }

  Future<void> tambahUser({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'nama': nama, 'role': role},
    );
  }

  Future<void> hapusUser(String id) async {
    await supabase.from('users').delete().match({'id_user': id});
  }
}
