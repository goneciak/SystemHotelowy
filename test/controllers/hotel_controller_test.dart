import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/controllers/hotel_controller.dart';
import 'package:hotel/enums/status_rezerwacji.dart';

void main() {
  group('HotelController', () {
    test('tworzy rezerwacje na podstawie danych demonstracyjnych', () {
      final controller = HotelController.demo();

      final rezerwacja = controller.utworzRezerwacje(
        idGoscia: 1,
        idPokoju: 1,
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
      );

      expect(rezerwacja.idRezerwacji, 1);
      expect(rezerwacja.gosc, controller.repozytorium.znajdzGosciaPoId(1));
      expect(rezerwacja.pokoje.single, controller.repozytorium.znajdzPokojPoId(1));
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
      final controller = HotelController.demo();

      final pokoje = controller.znajdzDostepnePokoje(
        dataPoczatkowa: DateTime(2026, 6, 10),
        dataKoncowa: DateTime(2026, 6, 12),
        liczbaGosci: 3,
      );

      expect(pokoje.map((pokoj) => pokoj.nrPokoju), [201, 301]);
    });

    test('zmienia status pokoju przez kontroler', () {
      final controller = HotelController.demo();

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
      final controller = HotelController.demo();
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

      expect(kodPin, 'PIN-101');
      expect(wymeldowano, isTrue);
      expect(rezerwacja.status, StatusRezerwacji.potwierdzona);
    });

    test('wykonuje platnosc za rezerwacje', () {
      final controller = HotelController.demo();
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

    test('zapisuje niepoprawna platnosc gdy system platnosci odrzuci transakcje', () {
      final controller = HotelController.demo(czyPlatnoscPoprawna: false);
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
    });

    test('modyfikuje daty rezerwacji przez kontroler', () {
      final controller = HotelController.demo();
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
      final controller = HotelController.demo();
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

    test('dodaje ocene pobytu do rezerwacji', () {
      final controller = HotelController.demo();
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

      expect(wynik, isTrue);
      expect(rezerwacja.ocenaPobytu?.liczbaGwiazdek, 5);
      expect(rezerwacja.ocenaPobytu?.komentarz, 'Bardzo dobry pobyt');
    });
  });
}
