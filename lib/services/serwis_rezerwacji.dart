import '../enums/status_pokoju.dart';
import '../enums/status_rezerwacji.dart';
import '../interfaces/i_serwis_email.dart';
import '../models/gosc.dart';
import '../models/pokoj.dart';
import '../models/rezerwacja.dart';

class SerwisRezerwacji {
  SerwisRezerwacji({
    required this.serwisEmail,
    required List<Pokoj> pokoje,
    List<Gosc>? goscie,
    DateTime? dzisiejszaData,
  }) : _pokoje = pokoje,
       _goscie = goscie ?? [],
       _dzisiejszaData = dzisiejszaData;

  final ISerwisEmail serwisEmail;
  final List<Pokoj> _pokoje;
  final List<Gosc> _goscie;
  final DateTime? _dzisiejszaData;
  final List<Rezerwacja> _rezerwacje = [];
  int _nastepneIdRezerwacji = 1;

  Rezerwacja stworzRezerwacje({
    required int idGoscia,
    required int idPokoju,
    required DateTime dataPoczatkowa,
    required DateTime dataKoncowa,
  }) {
    final pokoj = _znajdzPokoj(idPokoju);
    final gosc = _znajdzGoscia(idGoscia);
    if (_czyDataWPrzeszlosci(dataPoczatkowa)) {
      throw StateError('Nie mozna zarezerwowac pokoju w przeszlosci.');
    }

    if (!pokoj.czyDostepny(dataPoczatkowa, dataKoncowa)) {
      throw StateError('Pokoj nie jest dostepny w podanym terminie.');
    }

    final rezerwacja = Rezerwacja(
      idRezerwacji: _nastepneIdRezerwacji++,
      dataPoczatkowa: dataPoczatkowa,
      dataKoncowa: dataKoncowa,
      calkowitaCena: pokoj.obliczKoszt(
        dataKoncowa.difference(dataPoczatkowa).inDays,
      ),
      status: StatusRezerwacji.potwierdzona,
      gosc: gosc,
      pokoje: [pokoj],
    );

    _rezerwacje.add(rezerwacja);
    pokoj.rezerwacje.add(rezerwacja);
    pokoj.zmienStatus(StatusPokoju.zajety);
    serwisEmail.wyslijPotwierdzenie(
      gosc?.email ?? _tymczasowyEmailGoscia(idGoscia),
      rezerwacja.idRezerwacji,
    );

    return rezerwacja;
  }

  bool anulujRezerwacje({
    required int idRezerwacji,
    required String powod,
  }) {
    final dane = _znajdzRezerwacjeZPokojem(idRezerwacji);
    if (dane == null) {
      return false;
    }

    dane.rezerwacja.anulujRezerwacje();
    dane.pokoj.zmienStatus(StatusPokoju.dostepny);
    return true;
  }

  bool modyfikujDatyRezerwacji({
    required int idRezerwacji,
    required DateTime nowaDataPoczatkowa,
    required DateTime nowaDataKoncowa,
  }) {
    if (!nowaDataKoncowa.isAfter(nowaDataPoczatkowa)) {
      return false;
    }
    if (_czyDataWPrzeszlosci(nowaDataPoczatkowa)) {
      return false;
    }

    final dane = _znajdzRezerwacjeZPokojem(idRezerwacji);
    if (dane == null) {
      return false;
    }

    final koliduje = dane.pokoj.rezerwacje.any((rezerwacja) {
      if (rezerwacja.idRezerwacji == idRezerwacji ||
          rezerwacja.status == StatusRezerwacji.anulowana) {
        return false;
      }

      return _terminySiePokrywaja(
        nowaDataPoczatkowa,
        nowaDataKoncowa,
        rezerwacja.dataPoczatkowa,
        rezerwacja.dataKoncowa,
      );
    });

    if (koliduje) {
      return false;
    }

    final wynik = dane.rezerwacja.modyfikujDaty(
      nowaDataPoczatkowa,
      nowaDataKoncowa,
    );
    if (wynik) {
      dane.rezerwacja.calkowitaCena = dane.pokoj.obliczKoszt(
        dane.rezerwacja.obliczDlugoscPobytu(),
      );
    }

    return wynik;
  }

  List<Pokoj> znajdzDostepnePokoje({
    required DateTime dataPoczatkowa,
    required DateTime dataKoncowa,
    required int liczbaGosci,
  }) {
    return _pokoje.where((pokoj) {
      return pokoj.pojemnoscPokoju >= liczbaGosci &&
          pokoj.czyDostepny(dataPoczatkowa, dataKoncowa);
    }).toList();
  }

  Pokoj _znajdzPokoj(int idPokoju) {
    return _pokoje.firstWhere(
      (pokoj) => pokoj.idPokoju == idPokoju,
      orElse: () => throw StateError('Nie znaleziono pokoju.'),
    );
  }

  _RezerwacjaZPokojem? _znajdzRezerwacjeZPokojem(int idRezerwacji) {
    for (final pokoj in _pokoje) {
      for (final rezerwacja in pokoj.rezerwacje) {
        if (rezerwacja.idRezerwacji == idRezerwacji) {
          return _RezerwacjaZPokojem(rezerwacja: rezerwacja, pokoj: pokoj);
        }
      }
    }

    return null;
  }

  bool _terminySiePokrywaja(
    DateTime poczatekA,
    DateTime koniecA,
    DateTime poczatekB,
    DateTime koniecB,
  ) {
    return poczatekA.isBefore(koniecB) && koniecA.isAfter(poczatekB);
  }

  bool _czyDataWPrzeszlosci(DateTime data) {
    final dzisiaj = _dzisiejszaData;
    if (dzisiaj == null) {
      return false;
    }

    return _tylkoData(data).isBefore(_tylkoData(dzisiaj));
  }

  DateTime _tylkoData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  Gosc? _znajdzGoscia(int idGoscia) {
    for (final gosc in _goscie) {
      if (gosc.idUzytkownika == idGoscia) {
        return gosc;
      }
    }

    return null;
  }

  String _tymczasowyEmailGoscia(int idGoscia) {
    return 'gosc$idGoscia@example.local';
  }
}

class _RezerwacjaZPokojem {
  const _RezerwacjaZPokojem({
    required this.rezerwacja,
    required this.pokoj,
  });

  final Rezerwacja rezerwacja;
  final Pokoj pokoj;
}
