import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/enums/status_rezerwacji.dart';
import 'package:hotel/models/pokoj.dart';
import 'package:hotel/models/rezerwacja.dart';

void main() {
  group('Pokoj', () {
    test('jest dostepny gdy nie ma rezerwacji w podanym terminie', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 10), DateTime(2026, 6, 12)),
        isTrue,
      );
    });

    test('nie jest dostepny gdy aktywna rezerwacja pokrywa sie z terminem', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [
          Rezerwacja(
            idRezerwacji: 1,
            dataPoczatkowa: DateTime(2026, 6, 10),
            dataKoncowa: DateTime(2026, 6, 13),
            calkowitaCena: 900,
            status: StatusRezerwacji.potwierdzona,
          ),
        ],
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 12), DateTime(2026, 6, 14)),
        isFalse,
      );
    });

    test('jest dostepny gdy termin zaczyna sie w dniu wymeldowania', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [
          Rezerwacja(
            idRezerwacji: 1,
            dataPoczatkowa: DateTime(2026, 6, 10),
            dataKoncowa: DateTime(2026, 6, 13),
            calkowitaCena: 900,
            status: StatusRezerwacji.potwierdzona,
          ),
        ],
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 13), DateTime(2026, 6, 15)),
        isTrue,
      );
    });

    test('jest dostepny gdy nowy termin jest po zakonczonej rezerwacji', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [
          Rezerwacja(
            idRezerwacji: 1,
            dataPoczatkowa: DateTime(2026, 6, 9),
            dataKoncowa: DateTime(2026, 6, 12),
            calkowitaCena: 900,
            status: StatusRezerwacji.potwierdzona,
          ),
        ],
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 15), DateTime(2026, 6, 19)),
        isTrue,
      );
    });

    test('jest dostepny gdy nowy termin konczy sie przed rezerwacja', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [
          Rezerwacja(
            idRezerwacji: 1,
            dataPoczatkowa: DateTime(2026, 6, 15),
            dataKoncowa: DateTime(2026, 6, 19),
            calkowitaCena: 1200,
            status: StatusRezerwacji.potwierdzona,
          ),
        ],
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 9), DateTime(2026, 6, 12)),
        isTrue,
      );
    });

    test('anulowana rezerwacja nie blokuje dostepnosci pokoju', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
        rezerwacje: [
          Rezerwacja(
            idRezerwacji: 1,
            dataPoczatkowa: DateTime(2026, 6, 10),
            dataKoncowa: DateTime(2026, 6, 13),
            calkowitaCena: 900,
            status: StatusRezerwacji.anulowana,
          ),
        ],
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 11), DateTime(2026, 6, 12)),
        isTrue,
      );
    });

    test('nie jest dostepny gdy pokoj jest wylaczony', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.wylaczony,
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 10), DateTime(2026, 6, 12)),
        isFalse,
      );
    });

    test('nie jest dostepny gdy pokoj jest w trakcie czyszczenia', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.czyszczenie,
      );

      expect(
        pokoj.czyDostepny(DateTime(2026, 6, 10), DateTime(2026, 6, 12)),
        isFalse,
      );
    });

    test('zmienia status pokoju', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
      );

      pokoj.zmienStatus(StatusPokoju.czyszczenie);

      expect(pokoj.statusPokoju, StatusPokoju.czyszczenie);
    });

    test('oblicza koszt pobytu dla liczby dni', () {
      final pokoj = Pokoj(
        idPokoju: 101,
        nrPokoju: 101,
        pojemnoscPokoju: 2,
        cenaZaDobe: 300,
        statusPokoju: StatusPokoju.dostepny,
      );

      expect(pokoj.obliczKoszt(3), 900);
    });
  });
}
