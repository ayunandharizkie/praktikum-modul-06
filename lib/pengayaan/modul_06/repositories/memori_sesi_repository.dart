
import 'package:praktikum_modul_06/modul_06/models/sesi_pengguna.dart';
import 'package:praktikum_modul_06/modul_06/services/sesi_memori.dart';

import 'sesi_repository.dart';

class MemoriSesiRepository implements SesiRepository {
  MemoriSesiRepository(this._memori);

  final SesiMemori _memori;

  @override
  String get nama => 'Memori';

  @override
  String get keterangan =>
      'Sesi disimpan di memori aplikasi dan tidak bertahan setelah restart.';

  @override
  bool get bertahanSetelahRestart => false;

  @override
  Future<SesiPengguna?> baca() async {
    return _memori.baca();
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    await _memori.simpan(sesi);
  }

  @override
  Future<void> hapus() async {
    await _memori.hapus();
  }

  @override
  Future<bool> adaSesi() async {
    return _memori.adaSesi;
  }

  @override
  Future<String?> intipMentah() async {
    return null;
  }
}
