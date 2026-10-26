
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum_modul_06/modul_06/modul_06_app.dart';

void main() {
  testWidgets('Aplikasi Modul 06 menampilkan halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul06App());

    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Portal Akademik'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
