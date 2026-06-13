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
        kodPin: '1234',
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

      expect(kodPin, '1234');
      expect(rezerwacja.status, StatusRezerwacji.potwierdzona);
      expect(pokoj.statusPokoju, StatusPokoju.zajety);
      expect(systemDrzwi.aktywnePiny[101], isNull);
    });

    test('nie pozwala zameldowac anulowanej rezerwacji', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.anulowana,
        kodPin: '1234',
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
        kodPin: '1234',
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
      expect(rezerwacja.status, StatusRezerwacji.zakonczona);
      expect(pokoj.statusPokoju, StatusPokoju.czyszczenie);
      expect(systemDrzwi.aktywnePiny.containsKey(101), isFalse);
    });

    test('nie wymeldowuje drugi raz zakonczonej rezerwacji', () {
      final systemDrzwi = FakeSystemOtwieraniaDrzwi();
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.zakonczona,
        kodPin: '1234',
      );
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.czyszczenie,
        rezerwacje: [rezerwacja],
      );
      final serwis = SerwisZameldowania(
        systemOtwieraniaDrzwi: systemDrzwi,
        pokoje: [pokoj],
      );

      final wynik = serwis.przetworzWymeldowanie(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(wynik, isFalse);
      expect(rezerwacja.status, StatusRezerwacji.zakonczona);
      expect(pokoj.statusPokoju, StatusPokoju.czyszczenie);
    });

    test('nie wymeldowuje anulowanej rezerwacji', () {
      final systemDrzwi = FakeSystemOtwieraniaDrzwi();
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 750,
        status: StatusRezerwacji.anulowana,
        kodPin: '1234',
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
      expect(systemDrzwi.aktywnePiny[101], isNotNull);
    });
  });
}
