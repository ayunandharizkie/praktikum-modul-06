
import 'package:flutter/material.dart';
import 'package:praktikum_modul_06/modul_06/services/auth_api.dart';
import 'package:praktikum_modul_06/modul_06/services/sesi_memori.dart';

import 'controllers/sesi_controller.dart';
import 'repositories/aman_sesi_repository.dart';
import 'repositories/memori_sesi_repository.dart';
import 'repositories/prefs_sesi_repository.dart';
import 'repositories/sesi_repository.dart';
import 'screens/beranda_pengayaan_screens.dart';
import 'screens/login_pengayaan_screen.dart';
import 'storage/penyimpanan_aman_platform.dart';
import 'widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  const Modul06PengayaanApp({super.key});

  @override
  State<Modul06PengayaanApp> createState() =>
      _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState
    extends State<Modul06PengayaanApp> {
  late final SesiMemori _memori;
  late final AuthApi _api;

  late SesiRepository _repository;
  late SesiController _controller;

  String _jenisPenyimpanan = 'Secure Storage';

  @override
  void initState() {
    super.initState();

    _memori = SesiMemori();
    _api = const AuthApi();

    _repository = AmanSesiRepository(
      penyimpanan: PenyimpananAmanPlatform(),
    );

    _controller = _buatController(_repository);
    _controller.pulihkan();
  }

  SesiController _buatController(SesiRepository repository) {
    return SesiController(
      repository: repository,
      api: _api,
    );
  }

  Future<void> _gantiPenyimpanan(String? jenis) async {
    if (jenis == null || jenis == _jenisPenyimpanan) return;

    final SesiRepository repositoryBaru;

    switch (jenis) {
      case 'Memori':
        repositoryBaru = MemoriSesiRepository(_memori);
        break;
      case 'SharedPreferences':
        repositoryBaru = PrefsSesiRepository();
        break;
      case 'Secure Storage':
        repositoryBaru = AmanSesiRepository(
          penyimpanan: PenyimpananAmanPlatform(),
        );
        break;
      default:
        return;
    }

    final SesiController controllerLama = _controller;
    final SesiController controllerBaru =
        _buatController(repositoryBaru);

    setState(() {
      _jenisPenyimpanan = jenis;
      _repository = repositoryBaru;
      _controller = controllerBaru;
    });

    controllerLama.dispose();
    await controllerBaru.pulihkan();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 Pengayaan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mode penyimpanan sesi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _jenisPenyimpanan,
                      items: const [
                        DropdownMenuItem(
                          value: 'Memori',
                          child: Text('Memori'),
                        ),
                        DropdownMenuItem(
                          value: 'SharedPreferences',
                          child: Text('Preferences'),
                        ),
                        DropdownMenuItem(
                          value: 'Secure Storage',
                          child: Text('Secure Storage'),
                        ),
                      ],
                      onChanged: _gantiPenyimpanan,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GerbangSesi(
                  controller: _controller,
                  form: (context) => LoginPengayaanScreen(
                    controller: _controller,
                  ),
                  beranda: (context, sesi) =>
                      BerandaPengayaanScreen(
                    controller: _controller,
                    sesi: sesi,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
