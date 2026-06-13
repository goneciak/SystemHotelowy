import 'uzytkownik.dart';

class Recepcjonista extends Uzytkownik {
  Recepcjonista({
    required super.idUzytkownika,
    required super.imie,
    required super.nazwisko,
    required super.email,
    required super.nrTelefonu,
    required this.idPracownika,
    required this.rodzajZmian,
  });

  final int idPracownika;
  final String rodzajZmian;

  int getIdPracownika() {
    return idPracownika;
  }
}
