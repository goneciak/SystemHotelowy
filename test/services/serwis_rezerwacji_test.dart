import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/data/lokalne_repozytorium_hotelu.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/enums/status_rezerwacji.dart';
import 'package:hotel/fakes/fake_serwis_email.dart';
import 'package:hotel/models/gosc.dart';
import 'package:hotel/models/pokoj.dart';
import 'package:hotel/services/serwis_rezerwacji.dart';

void main() {
  group('SerwisRezerwacji', () {
    test('tworzy rezerwacje dla dostepnego pokoju', () {
      final email = FakeSerwisEmail();
      final gosc = Gosc(
        idUzytkownika: 7,
        imie: 'Jan',
        nazwisko: 'Kowalski',
        email: 'jan@example.local',
        nrTelefonu: '123456789',
        iloscPunktowLojalnosciowych: 0,
      );
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: email,
        pokoje: [pokoj],
        goscie: [gosc],
      );

      final rezerwacja = serwis.stworzRezerwacje(
        idGoscia: 7,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
      );

      expect(rezerwacja.idRezerwacji, 1);
      expect(rezerwacja.gosc, gosc);
      expect(rezerwacja.pokoje, [pokoj]);
      expect(rezerwacja.status, StatusRezerwacji.potwierdzona);
      expect(rezerwacja.calkowitaCena, 750);
      expect(pokoj.rezerwacje, contains(rezerwacja));
      expect(email.wyslanePotwierdzenia, hasLength(1));
      expect(email.wyslanePotwierdzenia.single.email, 'jan@example.local');
      expect(email.wyslanePotwierdzenia.single.idRezerwacji, 1);
    });

    test('nie tworzy rezerwacji gdy pokoj jest zajety w tym terminie', () {
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokoj],
      );

      serwis.stworzRezerwacje(
        idGoscia: 7,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
      );

      expect(
        () => serwis.stworzRezerwacje(
          idGoscia: 8,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 12),
          dataKoncowa: DateTime(2026, 6, 14),
        ),
        throwsStateError,
      );
    });

    test('nie tworzy rezerwacji gdy zakres dat jest niepoprawny', () {
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokoj],
      );

      expect(
        () => serwis.stworzRezerwacje(
          idGoscia: 7,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 12),
          dataKoncowa: DateTime(2026, 6, 12),
        ),
        throwsStateError,
      );
    });

    test('nie tworzy rezerwacji gdy data poczatkowa jest w przeszlosci', () {
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokoj],
        dzisiejszaData: DateTime(2026, 6, 13),
      );

      expect(
        () => serwis.stworzRezerwacje(
          idGoscia: 7,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 12),
          dataKoncowa: DateTime(2026, 6, 14),
        ),
        throwsStateError,
      );
    });

    test('zwraca pokoje dostepne dla liczby gosci i zakresu dat', () {
      final pokojDwuosobowy = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final pokojJednoosobowy = Pokoj(
        idPokoju: 2,
        nrPokoju: 102,
        pojemnoscPokoju: 1,
        cenaZaDobe: 180,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokojDwuosobowy, pokojJednoosobowy],
      );

      final dostepne = serwis.znajdzDostepnePokoje(
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
        liczbaGosci: 2,
      );

      expect(dostepne, [pokojDwuosobowy]);
    });

    test('nie zwraca pokoju z rezerwacja kolidujaca z terminem', () {
      final pokojDwuosobowy = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final pokojAlternatywny = Pokoj(
        idPokoju: 2,
        nrPokoju: 102,
        pojemnoscPokoju: 2,
        cenaZaDobe: 280,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokojDwuosobowy, pokojAlternatywny],
      );
      serwis.stworzRezerwacje(
        idGoscia: 7,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
      );

      final dostepne = serwis.znajdzDostepnePokoje(
        dataPoczatkowa: DateTime(2026, 6, 12),
        dataKoncowa: DateTime(2026, 6, 14),
        liczbaGosci: 2,
      );

      expect(dostepne, [pokojAlternatywny]);
    });

    test('nie zwraca pokoi wylaczonych ani w trakcie czyszczenia', () {
      final pokojDostepny = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final pokojCzyszczony = Pokoj(
        idPokoju: 2,
        nrPokoju: 102,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.czyszczenie,
      );
      final pokojWylaczony = Pokoj(
        idPokoju: 3,
        nrPokoju: 103,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.wylaczony,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokojDostepny, pokojCzyszczony, pokojWylaczony],
      );

      final dostepne = serwis.znajdzDostepnePokoje(
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
        liczbaGosci: 2,
      );

      expect(dostepne, [pokojDostepny]);
    });

    test('anuluje rezerwacje', () {
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokoj],
      );
      final rezerwacja = serwis.stworzRezerwacje(
        idGoscia: 7,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
      );

      final anulowano = serwis.anulujRezerwacje(
        idRezerwacji: rezerwacja.idRezerwacji,
        powod: 'Zmiana planow',
      );

      expect(anulowano, isTrue);
      expect(rezerwacja.status, StatusRezerwacji.anulowana);
      expect(pokoj.statusPokoju, StatusPokoju.dostepny);
    });

    test(
      'modyfikuje daty rezerwacji gdy pokoj jest dostepny w nowym terminie',
      () {
        final pokoj = Pokoj(
          idPokoju: 1,
          nrPokoju: 101,
          pojemnoscPokoju: 2,
          cenaZaDobe: 250,
          statusPokoju: StatusPokoju.dostepny,
        );
        final serwis = SerwisRezerwacji(
          serwisEmail: FakeSerwisEmail(),
          pokoje: [pokoj],
        );
        final rezerwacja = serwis.stworzRezerwacje(
          idGoscia: 7,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 10),
          dataKoncowa: DateTime(2026, 6, 12),
        );

        final wynik = serwis.modyfikujDatyRezerwacji(
          idRezerwacji: rezerwacja.idRezerwacji,
          nowaDataPoczatkowa: DateTime(2026, 6, 12),
          nowaDataKoncowa: DateTime(2026, 6, 14),
        );

        expect(wynik, isTrue);
        expect(rezerwacja.dataPoczatkowa, DateTime(2026, 6, 12));
        expect(rezerwacja.dataKoncowa, DateTime(2026, 6, 14));
        expect(rezerwacja.calkowitaCena, 500);
      },
    );

    test('nie modyfikuje dat gdy nowy termin koliduje z inna rezerwacja', () {
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokoj],
      );
      final pierwsza = serwis.stworzRezerwacje(
        idGoscia: 7,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );
      serwis.stworzRezerwacje(
        idGoscia: 8,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 13),
        dataKoncowa: DateTime(2026, 6, 15),
      );

      final wynik = serwis.modyfikujDatyRezerwacji(
        idRezerwacji: pierwsza.idRezerwacji,
        nowaDataPoczatkowa: DateTime(2026, 6, 12),
        nowaDataKoncowa: DateTime(2026, 6, 14),
      );

      expect(wynik, isFalse);
      expect(pierwsza.dataPoczatkowa, DateTime(2026, 6, 10));
      expect(pierwsza.dataKoncowa, DateTime(2026, 6, 12));
    });

    test('nie modyfikuje dat gdy nowy termin zaczyna sie w przeszlosci', () {
      final pokoj = Pokoj(
        idPokoju: 1,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 250,
        statusPokoju: StatusPokoju.dostepny,
      );
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: [pokoj],
        dzisiejszaData: DateTime(2026, 6, 13),
      );
      final rezerwacja = serwis.stworzRezerwacje(
        idGoscia: 7,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 13),
        dataKoncowa: DateTime(2026, 6, 15),
      );

      final wynik = serwis.modyfikujDatyRezerwacji(
        idRezerwacji: rezerwacja.idRezerwacji,
        nowaDataPoczatkowa: DateTime(2026, 6, 12),
        nowaDataKoncowa: DateTime(2026, 6, 14),
      );

      expect(wynik, isFalse);
      expect(rezerwacja.dataPoczatkowa, DateTime(2026, 6, 13));
      expect(rezerwacja.dataKoncowa, DateTime(2026, 6, 15));
    });

    test('korzysta z pokoi z lokalnego repozytorium demo', () {
      final repozytorium = LokalneRepozytoriumHotelu.demo();
      final serwis = SerwisRezerwacji(
        serwisEmail: FakeSerwisEmail(),
        pokoje: repozytorium.pokoje,
        goscie: repozytorium.goscie,
      );

      final rezerwacja = serwis.stworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      expect(rezerwacja.calkowitaCena, 500);
      expect(rezerwacja.gosc, repozytorium.znajdzGosciaPoId(1));
      expect(repozytorium.znajdzPokojPoId(1).rezerwacje, contains(rezerwacja));
    });
  });
}
