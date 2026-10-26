
import 'package:flutter/foundation.dart';
import 'package:praktikum_modul_06/modul_06/models/sesi_pengguna.dart';
import 'package:praktikum_modul_06/modul_06/services/auth_api.dart';

import '../repositories/sesi_repository.dart';

enum StatusSesi {
  memeriksa,
  keluar,
  memproses,
  masuk,
  gagal,
  kedaluwarsa,
}

class SesiController extends ChangeNotifier {
  SesiController({
    required this.repository,
    required this.api,
    DateTime Function()? jamSekarang,
  }) : _jamSekarang = jamSekarang ?? DateTime.now;

  final SesiRepository repository;
  final AuthApi api;
  final DateTime Function() _jamSekarang;

  StatusSesi _status = StatusSesi.memeriksa;
  SesiPengguna? _sesi;
  String? _pesan;

  int _nomorPercobaan = 0;

  StatusSesi get status => _status;
  SesiPengguna? get sesi => _sesi;
  String? get pesan => _pesan;

  void _perbarui({
    required StatusSesi status,
    SesiPengguna? sesi,
    String? pesan,
  }) {
    _status = status;
    _sesi = sesi;
    _pesan = pesan;

    notifyListeners();
  }

  Future<void> pulihkan() async {
    _perbarui(status: StatusSesi.memeriksa);

    try {
      final tersimpan = await repository.baca();

      if (tersimpan == null) {
        _perbarui(status: StatusSesi.keluar);
        return;
      }

      if (tersimpan.sudahKedaluwarsa(_jamSekarang())) {
        await repository.hapus();
        _perbarui(
          status: StatusSesi.kedaluwarsa,
          pesan: 'Sesi Anda sudah berakhir. Silakan masuk kembali.',
        );
        return;
      }

      _perbarui(
        status: StatusSesi.masuk,
        sesi: tersimpan,
      );
    } catch (e) {
      _perbarui(
        status: StatusSesi.gagal,
        pesan: 'Sesi tidak dapat dipulihkan. Silakan coba lagi.',
      );
    }
  }

  Future<bool> masuk({
    required String email,
    required String sandi,
  }) async {
    final percobaan = ++_nomorPercobaan;

    _perbarui(status: StatusSesi.memproses);

    try {
      final sesiBaru = await api.masuk(
        email: email,
        sandi: sandi,
      );

      if (percobaan != _nomorPercobaan) return false;

      await repository.simpan(sesiBaru);

      if (percobaan != _nomorPercobaan) {
        await repository.hapus();
        return false;
      }

      _perbarui(
        status: StatusSesi.masuk,
        sesi: sesiBaru,
      );

      return true;
    } on AuthException catch (e) {
      if (percobaan != _nomorPercobaan) return false;

      _perbarui(
        status: StatusSesi.gagal,
        pesan: e.pesan,
      );
      return false;
    } catch (e) {
      if (percobaan != _nomorPercobaan) return false;

      _perbarui(
        status: StatusSesi.gagal,
        pesan: 'Terjadi kesalahan. Silakan coba lagi.',
      );
      return false;
    }
  }

  void batalkanMasuk() {
    if (_status != StatusSesi.memproses) return;

    // Membuat hasil proses login yang lama tidak berlaku.
    _nomorPercobaan++;

    _perbarui(
      status: StatusSesi.keluar,
      pesan: 'Login dibatalkan.',
    );
  }

  Future<void> keluar() async {
    try {
      await repository.hapus();
      _perbarui(status: StatusSesi.keluar);
    } catch (e) {
      _perbarui(
        status: StatusSesi.gagal,
        sesi: _sesi,
        pesan: 'Sesi gagal dihapus. Silakan coba lagi.',
      );
    }
  }

  Future<void> perbaruiSesi() async {
    final sesiSaatIni = _sesi;

    if (sesiSaatIni == null) return;

    if (sesiSaatIni.sudahKedaluwarsa(_jamSekarang())) {
      await repository.hapus();
      _perbarui(
        status: StatusSesi.kedaluwarsa,
        pesan: 'Sesi sudah berakhir dan tidak dapat diperbarui.',
      );
      return;
    }

    _perbarui(
      status: StatusSesi.memproses,
      sesi: sesiSaatIni,
    );

    try {
      final sesiBaru = await api.perbaruiSesi(sesiSaatIni);
      await repository.simpan(sesiBaru);

      _perbarui(
        status: StatusSesi.masuk,
        sesi: sesiBaru,
      );
    } on AuthException catch (e) {
      _perbarui(
        status: StatusSesi.gagal,
        sesi: sesiSaatIni,
        pesan: e.pesan,
      );
    } catch (e) {
      _perbarui(
        status: StatusSesi.gagal,
        sesi: sesiSaatIni,
        pesan: 'Sesi gagal diperbarui. Silakan coba lagi.',
      );
    }
  }
}
