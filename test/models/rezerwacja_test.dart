import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/enums/status_rezerwacji.dart';
import 'package:hotel/models/gosc.dart';
import 'package:hotel/models/ocena_pobytu.dart';
import 'package:hotel/models/platnosc.dart';
import 'package:hotel/models/pokoj.dart';
import 'package:hotel/models/rezerwacja.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/fakes/fake_system_platnosci.dart';

void main() {
  group('Rezerwacja', () {
    test('oblicza dlugosc pobytu w dniach', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.oczekujaca,
      );

      expect(rezerwacja.obliczDlugoscPobytu(), 3);
    });

    test('potwierdza rezerwacje', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.oczekujaca,
      );

      rezerwacja.potwierdzRezerwacje();

      expect(rezerwacja.status, StatusRezerwacji.potwierdzona);
    });

    test('anuluje rezerwacje', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.potwierdzona,
      );

      rezerwacja.anulujRezerwacje();

      expect(rezerwacja.status, StatusRezerwacji.anulowana);
    });

    test('zmienia daty rezerwacji gdy data koncowa jest po poczatkowej', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.oczekujaca,
      );

      final wynik = rezerwacja.modyfikujDaty(
        DateTime(2026, 6, 11),
        DateTime(2026, 6, 15),
      );

      expect(wynik, isTrue);
      expect(rezerwacja.dataPoczatkowa, DateTime(2026, 6, 11));
      expect(rezerwacja.dataKoncowa, DateTime(2026, 6, 15));
      expect(rezerwacja.obliczDlugoscPobytu(), 4);
    });

    test('nie zmienia dat gdy data koncowa nie jest po poczatkowej', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.oczekujaca,
      );

      final wynik = rezerwacja.modyfikujDaty(
        DateTime(2026, 6, 15),
        DateTime(2026, 6, 15),
      );

      expect(wynik, isFalse);
      expect(rezerwacja.dataPoczatkowa, DateTime(2026, 6, 10));
      expect(rezerwacja.dataKoncowa, DateTime(2026, 6, 13));
    });

    test('przechowuje powiazania z gosciem, pokojami i platnoscia', () {
      final gosc = Gosc(
        idUzytkownika: 1,
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
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
      );
      final platnosc = Platnosc(
        idPlatnosci: 1,
        naleznoscDoZaplaty: 900,
        dataPlatnosci: DateTime(2026, 6, 10),
        systemPlatnosci: FakeSystemPlatnosci(),
      );

      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.potwierdzona,
        gosc: gosc,
        pokoje: [pokoj],
        platnosc: platnosc,
      );

      expect(rezerwacja.gosc, gosc);
      expect(rezerwacja.pokoje, [pokoj]);
      expect(rezerwacja.platnosc, platnosc);
    });

    test('dodaje ocene pobytu do rezerwacji', () {
      final rezerwacja = Rezerwacja(
        idRezerwacji: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 13),
        calkowitaCena: 900,
        status: StatusRezerwacji.zakonczona,
      );
      final ocena = OcenaPobytu(
        idOceny: 1,
        liczbaGwiazdek: 5,
        komentarz: 'Bardzo dobry pobyt',
        dataDodania: DateTime(2026, 6, 14),
      );

      final wynik = rezerwacja.dodajOcenePobytu(ocena);

      expect(wynik, isTrue);
      expect(rezerwacja.ocenaPobytu, ocena);
    });

  });
}
