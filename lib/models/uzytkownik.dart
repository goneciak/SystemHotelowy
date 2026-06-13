abstract class Uzytkownik {
  Uzytkownik({
    required this.idUzytkownika,
    required this.imie,
    required this.nazwisko,
    required this.email,
    required this.nrTelefonu,
  });

  final int idUzytkownika;
  final String imie;
  final String nazwisko;
  final String email;
  final String nrTelefonu;

  int getIdUzytkownika() {
    return idUzytkownika;
  }

  String getInformacjeKontaktowe() {
    return '$email, $nrTelefonu';
  }
}
