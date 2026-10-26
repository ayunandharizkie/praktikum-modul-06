
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'penyimpanan_aman.dart';

class PenyimpananAmanPlatform implements PenyimpananAman {
  PenyimpananAmanPlatform({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> tulis(String kunci, String nilai) async {
    await _storage.write(key: kunci, value: nilai);
  }

  @override
  Future<String?> baca(String kunci) async {
    return _storage.read(key: kunci);
  }

  @override
  Future<void> hapus(String kunci) async {
    await _storage.delete(key: kunci);
  }

  @override
  Future<String?> bacaMentah(String kunci) async {
    // Plugin tidak menyediakan pembacaan mentah melalui antarmuka ini.
    return null;
  }
}
