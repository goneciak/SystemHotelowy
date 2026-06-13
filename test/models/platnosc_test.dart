import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/fakes/fake_system_platnosci.dart';
import 'package:hotel/models/platnosc.dart';

void main() {
  group('Platnosc', () {
    test('wykonuje platnosc przez system platnosci', () {
      final systemPlatnosci = FakeSystemPlatnosci();
      final platnosc = Platnosc(
        idPlatnosci: 1,
        naleznoscDoZaplaty: 750,
        dataPlatnosci: DateTime(2026, 6, 10),
        systemPlatnosci: systemPlatnosci,
      );

      final wynik = platnosc.wykonajPlatnosc();

      expect(wynik, isTrue);
      expect(platnosc.czyPoprawna, isTrue);
      expect(systemPlatnosci.przetworzoneKwoty, [750]);
    });

    test('oznacza platnosc jako niepoprawna gdy system odrzuci transakcje', () {
      final systemPlatnosci = FakeSystemPlatnosci(czyPlatnoscPoprawna: false);
      final platnosc = Platnosc(
        idPlatnosci: 1,
        naleznoscDoZaplaty: 750,
        dataPlatnosci: DateTime(2026, 6, 10),
        systemPlatnosci: systemPlatnosci,
      );

      final wynik = platnosc.wykonajPlatnosc();

      expect(wynik, isFalse);
      expect(platnosc.czyPoprawna, isFalse);
      expect(systemPlatnosci.przetworzoneKwoty, [750]);
    });

    test('nie wykonuje platnosci dla kwoty mniejszej lub rownej zero', () {
      final systemPlatnosci = FakeSystemPlatnosci();
      final platnosc = Platnosc(
        idPlatnosci: 1,
        naleznoscDoZaplaty: 0,
        dataPlatnosci: DateTime(2026, 6, 10),
        systemPlatnosci: systemPlatnosci,
      );

      final wynik = platnosc.wykonajPlatnosc();

      expect(wynik, isFalse);
      expect(platnosc.czyPoprawna, isFalse);
      expect(systemPlatnosci.przetworzoneKwoty, isEmpty);
    });
  });
}
