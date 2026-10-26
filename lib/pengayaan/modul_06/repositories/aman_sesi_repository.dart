
import 'dart:convert';

import 'package:praktikum_modul_06/modul_06/models/sesi_pengguna.dart';

import '../storage/penyimpanan_aman.dart';
import 'sesi_repository.dart';

class AmanSesiRepository implements SesiRepository {
  AmanSesiRepository({
  required this._penyimpanan,
  this.kunciSesi = 'sesi_pengguna_pengayaan',
});

  final PenyimpananAman _penyimpanan;
  final String kunciSesi;

  @override
  String get nama => 'Secure Storage';

  @override
  String get keterangan =>
      'Sesi disimpan melalui API penyimpanan aman, bukan preferensi biasa.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final String? data = await _penyimpanan.baca(kunciSesi);

    if (data == null) return null;

    try {
      final dynamic hasil = jsonDecode(data);

      if (hasil is! Map<String, dynamic>) {
        await _penyimpanan.hapus(kunciSesi);
        return null;
      }

      return SesiPengguna.fromJson(hasil);
    } on FormatException {
      await _penyimpanan.hapus(kunciSesi);
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    await _penyimpanan.tulis(
      kunciSesi,
      jsonEncode(sesi.toJson()),
    );
  }

  @override
  Future<void> hapus() async {
    await _penyimpanan.hapus(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    return await baca() != null;
  }

  @override
  Future<String?> intipMentah() {
    return _penyimpanan.bacaMentah(kunciSesi);
  }
}
