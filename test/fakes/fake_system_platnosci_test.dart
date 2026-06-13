import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/fakes/fake_system_platnosci.dart';

void main() {
  group('FakeSystemPlatnosci', () {
    test('zwraca skonfigurowany wynik platnosci i zapisuje kwote', () {
      final systemPlatnosci = FakeSystemPlatnosci(czyPlatnoscPoprawna: false);

      final wynik = systemPlatnosci.przetworzPlatnosc(500);

      expect(wynik, isFalse);
      expect(systemPlatnosci.przetworzoneKwoty, [500]);
    });
  });
}
