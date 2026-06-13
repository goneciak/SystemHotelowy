import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/models/gosc.dart';

void main() {
  group('Gosc', () {
    test('dodaje punkty lojalnosciowe', () {
      final gosc = Gosc(
        idUzytkownika: 1,
        imie: 'Jan',
        nazwisko: 'Kowalski',
        email: 'jan@example.local',
        nrTelefonu: '123456789',
        iloscPunktowLojalnosciowych: 10,
      );

      gosc.dodajPunktyLojalnosciowe(15);

      expect(gosc.iloscPunktowLojalnosciowych, 25);
    });

    test('nie dodaje ujemnych punktow lojalnosciowych', () {
      final gosc = Gosc(
        idUzytkownika: 1,
        imie: 'Jan',
        nazwisko: 'Kowalski',
        email: 'jan@example.local',
        nrTelefonu: '123456789',
        iloscPunktowLojalnosciowych: 10,
      );

      gosc.dodajPunktyLojalnosciowe(-5);

      expect(gosc.iloscPunktowLojalnosciowych, 10);
    });
  });
}
