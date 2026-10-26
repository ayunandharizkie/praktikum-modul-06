import 'dart:async';

import 'package:flutter/material.dart';
import 'package:praktikum_modul_06/modul_06/models/sesi_pengguna.dart';

import '../controllers/sesi_controller.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';

class BerandaPengayaanScreen extends StatefulWidget {
  const BerandaPengayaanScreen({
    super.key,
    required this.controller,
    required this.sesi,
  });

  final SesiController controller;
  final SesiPengguna sesi;

  @override
  State<BerandaPengayaanScreen> createState() =>
      _BerandaPengayaanScreenState();
}

class _BerandaPengayaanScreenState
    extends State<BerandaPengayaanScreen> {
  late DateTime _sekarang;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _sekarang = DateTime.now();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          _sekarang = DateTime.now();
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) {
      return 'Sudah berakhir';
    }

    final jam = sisa.inHours;
    final menit = sisa.inMinutes.remainder(60);
    final detik = sisa.inSeconds.remainder(60);

    if (jam > 0) {
      return '$jam jam $menit menit $detik detik';
    }

    if (menit > 0) {
      return '$menit menit $detik detik';
    }

    return '$detik detik';
  }

  @override
  Widget build(BuildContext context) {
    final sesi = widget.sesi;
    final controller = widget.controller;

    final sisa = sesi.sisaWaktu(_sekarang);
    final warnaSisa = sisa < const Duration(minutes: 5)
        ? Colors.red
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Pengayaan Fase B'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: controller.keluar,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_outline),
              ),
              title: Text(sesi.nama),
              subtitle: Text(sesi.email),
              trailing: const Icon(Icons.verified_user_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Sesi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _BarisInfo(
                    label: 'Peran',
                    nilai: sesi.peran,
                  ),
                  _BarisInfo(
                    label: 'Masuk pada',
                    nilai: sesi.masukPada,
                  ),
                  _BarisInfo(
                    label: 'Kedaluwarsa pada',
                    nilai: sesi.kedaluwarsaPada,
                  ),
                  const Divider(height: 24),
                  Text(
                    'Sisa Masa Berlaku Sesi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatSisa(sisa),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: warnaSisa,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pengelolaan Sesi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      final sedangMemproses =
                          controller.status == StatusSesi.memproses;

                      return FilledButton.icon(
                        onPressed: sedangMemproses
                            ? null
                            : controller.perbaruiSesi,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Perbarui Sesi'),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Perbarui masa berlaku sesi menggunakan API demo.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PapanDiagnostikPenyimpanan(
            repository: controller.repository,
          ),
        ],
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({
    required this.label,
    required this.nilai,
  });

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label),
          ),
          const Text(': '),
          Expanded(
            child: SelectableText(nilai),
          ),
        ],
      ),
    );
  }
}