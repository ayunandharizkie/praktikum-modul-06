
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:praktikum_modul_06/modul_06/models/sesi_pengguna.dart';

import 'sesi_repository.dart';

class PrefsSesiRepository implements SesiRepository {
  PrefsSesiRepository({
  this._prefs,
  this.kunciSesi = 'sesi_pengguna_pengayaan',
});

  final SharedPreferences? _prefs;
  final String kunciSesi;

  Future<SharedPreferences> get _penyimpanan async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  String get nama => 'SharedPreferences';

  @override
  String get keterangan =>
      'Sesi disimpan di preferensi biasa dan dapat dibaca melalui API preferensi.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final SharedPreferences prefs = await _penyimpanan;
    final String? data = prefs.getString(kunciSesi);

    if (data == null) return null;

    try {
      final dynamic hasil = jsonDecode(data);

      if (hasil is! Map<String, dynamic>) {
        await prefs.remove(kunciSesi);
        return null;
      }

      return SesiPengguna.fromJson(hasil);
    } on FormatException {
      await prefs.remove(kunciSesi);
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final SharedPreferences prefs = await _penyimpanan;
    await prefs.setString(kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final SharedPreferences prefs = await _penyimpanan;
    await prefs.remove(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    return await baca() != null;
  }

  @override
  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _penyimpanan;
    return prefs.getString(kunciSesi);
  }
}
