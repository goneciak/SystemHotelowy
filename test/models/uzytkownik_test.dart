import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/models/gosc.dart';
import 'package:hotel/models/recepcjonista.dart';

void main() {
  group('Uzytkownik', () {
    test('gosc dziedziczy dane kontaktowe uzytkownika', () {
      final gosc = Gosc(
        idUzytkownika: 1,
        imie: 'Jan',
        nazwisko: 'Kowalski',
        email: 'jan@example.local',
        nrTelefonu: '123456789',
        iloscPunktowLojalnosciowych: 10,
      );

      expect(gosc.getIdUzytkownika(), 1);
      expect(gosc.getInformacjeKontaktowe(), 'jan@example.local, 123456789');
    });

    test('recepcjonista zwraca id pracownika', () {
      final recepcjonista = Recepcjonista(
        idUzytkownika: 2,
        imie: 'Anna',
        nazwisko: 'Nowak',
        email: 'anna@example.local',
        nrTelefonu: '987654321',
        idPracownika: 100,
        rodzajZmian: 'poranna',
      );

      expect(recepcjonista.getIdPracownika(), 100);
      expect(recepcjonista.getInformacjeKontaktowe(), 'anna@example.local, 987654321');
    });
  });
}
