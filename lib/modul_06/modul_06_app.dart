
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_api.dart';
import 'services/sesi_memori.dart';

class Modul06App extends StatefulWidget {
  const Modul06App({
    super.key,
    this.api,
    this.sesiMemori,
  });

  final AuthApi? api;
  final SesiMemori? sesiMemori;

  static const bool lambatSimulasi =
      bool.fromEnvironment('LAMBAT');

  @override
  State<Modul06App> createState() => _Modul06AppState();
}

class _Modul06AppState extends State<Modul06App> {
  late final SesiMemori _sesiMemori;
  late final AuthApi _api;

  @override
  void initState() {
    super.initState();

    _sesiMemori = widget.sesiMemori ?? SesiMemori();

    _api = widget.api ??
        AuthApi(
          tunda: Modul06App.lambatSimulasi
              ? const Duration(seconds: 2)
              : const Duration(milliseconds: 700),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 — Login & Sesi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
        ),
        useMaterial3: true,
      ),
      home: LoginScreen(
        api: _api,
        sesiMemori: _sesiMemori,
      ),
    );
  }
}
