import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/enums/status_rezerwacji.dart';
import 'package:hotel/fakes/fake_system_otwierania_drzwi.dart';
import 'package:hotel/models/pokoj.dart';
import 'package:hotel/models/rezerwacja.dart';
import 'package:hotel/services/serwis_zameldowania.dart';

void main() {
  group('SerwisZameldowania', () {
    test('przetwarza zameldowanie i zwraca kod PIN', () {
      final systemDrzwi = FakeSystemOtwieraniaDrzwi();
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.potwierdzona,
      );
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [rezerwacja],
      );
      final serwis = SerwisZameldowania(
        systemOtwieraniaDrzwi: systemDrzwi,
        pokoje: [pokoj],
      );

      final kodPin = serwis.przetworzZameldowanie(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(kodPin, 'PIN-101');
      expect(rezerwacja.status, StatusRezerwacji.potwierdzona);
      expect(pokoj.statusPokoju, StatusPokoju.zajety);
      expect(systemDrzwi.aktywnePiny[101], 'PIN-101');
    });

    test('nie pozwala zameldowac anulowanej rezerwacji', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.anulowana,
      );
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [rezerwacja],
      );
      final serwis = SerwisZameldowania(
        systemOtwieraniaDrzwi: FakeSystemOtwieraniaDrzwi(),
        pokoje: [pokoj],
      );

      expect(
        () => serwis.przetworzZameldowanie(
          idRezerwacji: rezerwacja.idRezerwacji,
        ),
        throwsStateError,
      );
    });

    test('przetwarza wymeldowanie i dezaktywuje kod PIN', () {
      final systemDrzwi = FakeSystemOtwieraniaDrzwi();
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.potwierdzona,
      );
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.zajety,
        rezerwacje: [rezerwacja],
      );
      final serwis = SerwisZameldowania(
        systemOtwieraniaDrzwi: systemDrzwi,
        pokoje: [pokoj],
      );
      systemDrzwi.stworzKodPIN(101);

      final wynik = serwis.przetworzWymeldowanie(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(wynik, isTrue);
      expect(rezerwacja.status, StatusRezerwacji.potwierdzona);
      expect(pokoj.statusPokoju, StatusPokoju.czyszczenie);
      expect(systemDrzwi.aktywnePiny.containsKey(101), isFalse);
    });

    test('nie wymeldowuje anulowanej rezerwacji', () {
      final systemDrzwi = FakeSystemOtwieraniaDrzwi();
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.anulowana,
      );
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.zajety,
        rezerwacje: [rezerwacja],
      );
      final serwis = SerwisZameldowania(
        systemOtwieraniaDrzwi: systemDrzwi,
        pokoje: [pokoj],
      );
      systemDrzwi.stworzKodPIN(101);

      final wynik = serwis.przetworzWymeldowanie(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(wynik, isFalse);
      expect(rezerwacja.status, StatusRezerwacji.anulowana);
      expect(pokoj.statusPokoju, StatusPokoju.zajety);
      expect(systemDrzwi.aktywnePiny[101], 'PIN-101');
    });
  });
}
