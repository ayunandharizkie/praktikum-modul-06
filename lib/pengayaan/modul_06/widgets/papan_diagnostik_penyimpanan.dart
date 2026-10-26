
import 'package:flutter/material.dart';

import '../repositories/sesi_repository.dart';

class PapanDiagnostikPenyimpanan extends StatefulWidget {
  const PapanDiagnostikPenyimpanan({
    super.key,
    required this.repository,
  });

  final SesiRepository repository;

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  String? _nilaiMentah;
  bool _memuat = true;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _bacaDiagnostik();
  }

  @override
  void didUpdateWidget(covariant PapanDiagnostikPenyimpanan oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.repository != widget.repository) {
      _bacaDiagnostik();
    }
  }

  Future<void> _bacaDiagnostik() async {
    setState(() {
      _memuat = true;
      _pesanError = null;
    });

    try {
      final String? hasil = await widget.repository.intipMentah();

      if (!mounted) return;

      setState(() {
        _nilaiMentah = hasil;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pesanError = 'Data diagnostik tidak dapat dibaca.';
        _memuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Papan Diagnostik Penyimpanan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Perbandingan kemampuan membaca data melalui API aplikasi. '
              'Ini bukan pemeriksaan forensik isi perangkat.',
            ),
            const Divider(height: 24),
            Text(
              widget.repository.nama,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(widget.repository.keterangan),
            const SizedBox(height: 12),
            _BarisDiagnostik(
              label: 'Bertahan setelah restart',
              nilai: widget.repository.bertahanSetelahRestart
                  ? 'Ya'
                  : 'Tidak',
            ),
            const SizedBox(height: 8),
            Text(
              'Hasil pembacaan melalui API aplikasi:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (_memuat)
              const Center(child: CircularProgressIndicator())
            else if (_pesanError != null)
              Text(
                _pesanError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _nilaiMentah ?? 'Tidak tersedia melalui API ini.',
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _bacaDiagnostik,
              icon: const Icon(Icons.refresh),
              label: const Text('Baca Ulang Diagnostik'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catatan: nilai yang tidak tersedia melalui API bukan bukti '
              'bahwa data tidak ada di penyimpanan perangkat.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisDiagnostik extends StatelessWidget {
  const _BarisDiagnostik({
    required this.label,
    required this.nilai,
  });

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Text(
          nilai,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
