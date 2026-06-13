import '../enums/status_pokoju.dart';
import '../enums/status_rezerwacji.dart';
import '../interfaces/i_system_otwierania_drzwi.dart';
import '../models/pokoj.dart';
import '../models/rezerwacja.dart';

class SerwisZameldowania {
  SerwisZameldowania({
    required this.systemOtwieraniaDrzwi,
    required List<Pokoj> pokoje,
  }) : _pokoje = pokoje;

  final ISystemOtwieraniaDrzwi systemOtwieraniaDrzwi;
  final List<Pokoj> _pokoje;

  String przetworzZameldowanie({required int idRezerwacji}) {
    final dane = _znajdzRezerwacjeZPokojem(idRezerwacji);
    if (dane.rezerwacja.status == StatusRezerwacji.anulowana ||
        dane.rezerwacja.status == StatusRezerwacji.zakonczona) {
      throw StateError('Rezerwacja nie moze zostac zameldowana.');
    }

    dane.rezerwacja.potwierdzRezerwacje();
    dane.pokoj.zmienStatus(StatusPokoju.zajety);
    final kodPin = dane.rezerwacja.kodPin;
    if (kodPin == null) {
      throw StateError('Rezerwacja nie ma przypisanego kodu PIN.');
    }

    return kodPin;
  }

  bool przetworzWymeldowanie({required int idRezerwacji}) {
    final dane = _znajdzRezerwacjeZPokojem(idRezerwacji);
    if (dane.rezerwacja.status == StatusRezerwacji.anulowana ||
        dane.rezerwacja.status == StatusRezerwacji.zakonczona) {
      return false;
    }

    systemOtwieraniaDrzwi.dezaktywujKodPIN(dane.pokoj.nrPokoju);
    dane.rezerwacja.status = StatusRezerwacji.zakonczona;
    dane.pokoj.zmienStatus(StatusPokoju.czyszczenie);
    return true;
  }

  _RezerwacjaZPokojem _znajdzRezerwacjeZPokojem(int idRezerwacji) {
    for (final pokoj in _pokoje) {
      for (final rezerwacja in pokoj.rezerwacje) {
        if (rezerwacja.idRezerwacji == idRezerwacji) {
          return _RezerwacjaZPokojem(rezerwacja: rezerwacja, pokoj: pokoj);
        }
      }
    }

    throw StateError('Nie znaleziono rezerwacji.');
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
