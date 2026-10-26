
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_modul_06/modul_06/services/auth_api.dart';

void main() {
  test('Akun belum aktif menghasilkan error 403', () async {
    const api = AuthApi(tunda: Duration.zero);

    expect(
      () => api.masuk(
        email: 'belumaktif@trpl.test',
        sandi: 'belajar123',
      ),
      throwsA(
        isA<AuthException>()
            .having((e) => e.kode, 'kode', 403)
            .having(
              (e) => e.pesan,
              'pesan',
              'Akun belum diaktivasi. Silakan aktivasi akun terlebih dahulu.',
            ),
      ),
    );
  });
}
