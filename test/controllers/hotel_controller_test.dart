import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/controllers/hotel_controller.dart';
import 'package:hotel/enums/status_rezerwacji.dart';

void main() {
  group('HotelController', () {
    HotelController controllerDemo({bool czyPlatnoscPoprawna = true}) {
      return HotelController.demo(
        czyPlatnoscPoprawna: czyPlatnoscPoprawna,
        dzisiejszaData: DateTime(2026, 6, 1),
      );
    }

    test('tworzy rezerwacje na podstawie danych demonstracyjnych', () {
      final controller = controllerDemo();

      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      expect(rezerwacja.idRezerwacji, 1);
      expect(rezerwacja.gosc, controller.repozytorium.znajdzGosciaPoId(1));
      expect(
        rezerwacja.pokoje.single,
        controller.repozytorium.znajdzPokojPoId(1),
      );
      expect(rezerwacja.kodPin, matches(RegExp(r'^\d{4}$')));
      expect(controller.rezerwacje, contains(rezerwacja));
      expect(controller.serwisEmail.wyslanePotwierdzenia, hasLength(1));
      expect(
        controller.serwisEmail.wyslanePotwierdzenia.single.email,
        'jan.kowalski@example.local',
      );
      expect(
        controller.serwisEmail.wyslanePotwierdzenia.single.idRezerwacji,
        rezerwacja.idRezerwacji,
      );
    });

    test('zwraca dostepne pokoje dla liczby gosci i zakresu dat', () {
      final controller = controllerDemo();

      final pokoje = controller.znajdzDostepnePokoje(
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
        liczbaGosci: 3,
      );

      expect(pokoje.map((pokoj) => pokoj.nrPokoju), [201, 301]);
    });

    test('zmienia status pokoju przez kontroler', () {
      final controller = controllerDemo();

      controller.zmienStatusPokoju(
        idPokoju: 1,
        nowyStatus: StatusPokoju.czyszczenie,
      );

      expect(
        controller.repozytorium.znajdzPokojPoId(1).statusPokoju,
        StatusPokoju.czyszczenie,
      );
    });

    test('przeprowadza zameldowanie i wymeldowanie rezerwacji', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      final kodPin = controller.zamelduj(
        idRezerwacji: rezerwacja.idRezerwacji,
      );
      final wymeldowano = controller.wymelduj(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(kodPin, rezerwacja.kodPin);
      expect(kodPin, matches(RegExp(r'^\d{4}$')));
      expect(wymeldowano, isTrue);
      expect(rezerwacja.status, StatusRezerwacji.zakonczona);
    });

    test('wykonuje platnosc za rezerwacje', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      final platnosc = controller.wykonajPlatnosc(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(platnosc.czyPoprawna, isTrue);
      expect(platnosc.naleznoscDoZaplaty, rezerwacja.calkowitaCena);
      expect(rezerwacja.platnosc, platnosc);
    });

    test('nie wykonuje drugi raz poprawnie oplaconej rezerwacji', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      final pierwszaPlatnosc = controller.wykonajPlatnosc(
        idRezerwacji: rezerwacja.idRezerwacji,
      );
      final drugaPlatnosc = controller.wykonajPlatnosc(
        idRezerwacji: rezerwacja.idRezerwacji,
      );

      expect(drugaPlatnosc, same(pierwszaPlatnosc));
      expect(controller.systemPlatnosci.przetworzoneKwoty, [500]);
    });

    test(
      'zapisuje niepoprawna platnosc gdy system platnosci odrzuci transakcje',
      () {
        final controller = controllerDemo(czyPlatnoscPoprawna: false);
        final rezerwacja = controller.utworzRezerwacje(
          idGoscia: 1,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 10),
          dataKoncowa: DateTime(2026, 6, 12),
        );

        final platnosc = controller.wykonajPlatnosc(
          idRezerwacji: rezerwacja.idRezerwacji,
        );

        expect(platnosc.czyPoprawna, isFalse);
        expect(rezerwacja.platnosc, platnosc);
        expect(controller.systemPlatnosci.przetworzoneKwoty, [500]);
      },
    );

    test('modyfikuje daty rezerwacji przez kontroler', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      final wynik = controller.modyfikujDatyRezerwacji(
        idRezerwacji: rezerwacja.idRezerwacji,
        nowaDataPoczatkowa: DateTime(2026, 6, 12),
        nowaDataKoncowa: DateTime(2026, 6, 15),
      );

      expect(wynik, isTrue);
      expect(rezerwacja.dataPoczatkowa, DateTime(2026, 6, 12));
      expect(rezerwacja.dataKoncowa, DateTime(2026, 6, 15));
      expect(rezerwacja.calkowitaCena, 750);
    });

    test('anuluje rezerwacje przez kontroler', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      final wynik = controller.anulujRezerwacje(
        idRezerwacji: rezerwacja.idRezerwacji,
        powod: 'Zmiana planow',
      );

      expect(wynik, isTrue);
      expect(rezerwacja.status, StatusRezerwacji.anulowana);
      expect(
        controller.repozytorium.znajdzPokojPoId(1).statusPokoju,
        StatusPokoju.dostepny,
      );
    });

    test(
      'po anulowaniu pozwala innej osobie zarezerwowac ten sam pokoj w tym samym terminie',
      () {
        final controller = controllerDemo();
        final pierwszaRezerwacja = controller.utworzRezerwacje(
          idGoscia: 1,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 10),
          dataKoncowa: DateTime(2026, 6, 12),
        );

        controller.anulujRezerwacje(
          idRezerwacji: pierwszaRezerwacja.idRezerwacji,
          powod: 'Zmiana planow',
        );

        final drugaRezerwacja = controller.utworzRezerwacje(
          idGoscia: 2,
          idPokoju: 1,
          dataPoczatkowa: DateTime(2026, 6, 10),
          dataKoncowa: DateTime(2026, 6, 12),
        );

        expect(pierwszaRezerwacja.status, StatusRezerwacji.anulowana);
        expect(
          drugaRezerwacja.gosc,
          controller.repozytorium.znajdzGosciaPoId(2),
        );
        expect(drugaRezerwacja.pokoje.single.idPokoju, 1);
        expect(drugaRezerwacja.status, StatusRezerwacji.potwierdzona);
      },
    );

    test('dodaje ocene pobytu do rezerwacji', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );
      controller.wymelduj(idRezerwacji: rezerwacja.idRezerwacji);

      final wynik = controller.dodajOcenePobytu(
        idRezerwacji: rezerwacja.idRezerwacji,
        liczbaGwiazdek: 5,
        komentarz: 'Bardzo dobry pobyt',
        dataDodania: DateTime(2026, 6, 13),
      );

      expect(wynik, isTrue);
      expect(rezerwacja.ocenaPobytu?.liczbaGwiazdek, 5);
      expect(rezerwacja.ocenaPobytu?.komentarz, 'Bardzo dobry pobyt');
    });

    test('nie dodaje oceny pobytu przed wymeldowaniem', () {
      final controller = controllerDemo();
      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      final wynik = controller.dodajOcenePobytu(
        idRezerwacji: rezerwacja.idRezerwacji,
        liczbaGwiazdek: 5,
        komentarz: 'Bardzo dobry pobyt',
        dataDodania: DateTime(2026, 6, 13),
      );

      expect(wynik, isFalse);
      expect(rezerwacja.ocenaPobytu, isNull);
    });
  });
}
