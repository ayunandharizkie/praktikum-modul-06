
import 'package:flutter/material.dart';

import '../models/sesi_pengguna.dart';

class KartuSesi extends StatelessWidget {
  final SesiPengguna sesi;

  /// Waktu acuan untuk menghitung sisa masa berlaku.
  final DateTime sekarang;

  final VoidCallback? onKeluar;
  final bool sedangKeluar;

  /// Menampilkan token apa adanya. Default false.
  final bool tampilkanToken;

  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.tampilkanToken = false,
  });

  /// Menyamarkan token: hanya 6 karakter awal yang terlihat.
  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';
    if (token.length <= 6) return _titik(token.length);
    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) =>
      List<String>.filled(jumlah, '\u2022').join();

  /// Mengubah waktu ISO-8601 menjadi format yang mudah dibaca.
  static String formatWaktu(String iso) {
    const List<String> bulan = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final DateTime? waktu = DateTime.tryParse(iso);
    if (waktu == null) return 'tidak diketahui';

    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');

    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}, '
        '$jam:$menit';
  }

  /// Mengubah Duration menjadi teks yang mudah dibaca.
  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir';
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik';
    if (sisa.inHours < 1) return '${sisa.inMinutes} menit';

    final int menit = sisa.inMinutes.remainder(60);

    return menit == 0
        ? '${sisa.inHours} jam'
        : '${sisa.inHours} jam $menit menit';
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final kedaluwarsa = sesi.sudahKedaluwarsa(sekarang);
    final sisa = sesi.sisaWaktu(sekarang);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: warna.primaryContainer,
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: warna.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sesi.nama,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(sesi.email),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _barisInfo(
              'Peran',
              SesiPengguna.labelPeran(sesi.peran),
            ),
            _barisInfo(
              'Waktu masuk',
              formatWaktu(sesi.masukPada),
            ),
            _barisInfo(
              'Sisa waktu',
              kedaluwarsa ? 'sudah berakhir' : formatSisa(sisa),
            ),
            _barisInfo(
              'Token',
              tampilkanToken
                  ? sesi.token
                  : samarkanToken(sesi.token),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: sedangKeluar ? null : onKeluar,
                icon: sedangKeluar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(sedangKeluar ? 'Keluar…' : 'Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisInfo(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: SelectableText(nilai)),
        ],
      ),
    );
  }
}
