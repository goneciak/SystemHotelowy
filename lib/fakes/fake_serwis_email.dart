import '../interfaces/i_serwis_email.dart';

class FakeSerwisEmail implements ISerwisEmail {
  final List<WyslanePotwierdzenie> wyslanePotwierdzenia = [];

  @override
  void wyslijPotwierdzenie(String email, int idRezerwacji) {
    wyslanePotwierdzenia.add(
      WyslanePotwierdzenie(email: email, idRezerwacji: idRezerwacji),
    );
  }
}

class WyslanePotwierdzenie {
  const WyslanePotwierdzenie({
    required this.email,
    required this.idRezerwacji,
  });

  final String email;
  final int idRezerwacji;
}
