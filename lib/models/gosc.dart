import 'uzytkownik.dart';

class Gosc extends Uzytkownik {
  Gosc({
    required super.idUzytkownika,
    required super.imie,
    required super.nazwisko,
    required super.email,
    required super.nrTelefonu,
    required this.iloscPunktowLojalnosciowych,
  });

  int iloscPunktowLojalnosciowych;

  void dodajPunktyLojalnosciowe(int punkty) {
    if (punkty <= 0) {
      return;
    }

    iloscPunktowLojalnosciowych += punkty;
  }
}
