
import 'package:flutter/material.dart';
import 'package:praktikum_modul_06/modul_06/models/sesi_pengguna.dart';

import '../controllers/sesi_controller.dart';

class GerbangSesi extends StatelessWidget {
  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  final SesiController controller;
  final WidgetBuilder form;
  final Widget Function(BuildContext context, SesiPengguna sesi)
      beranda;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case StatusSesi.memproses:
            if (controller.sesi != null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return form(context);

          case StatusSesi.masuk:
            final SesiPengguna? sesi = controller.sesi;

            if (sesi == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Data sesi tidak tersedia.'),
                ),
              );
            }

            return beranda(context, sesi);

          case StatusSesi.keluar:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
            return form(context);
        }
      },
    );
  }
}
