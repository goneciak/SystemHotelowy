import '../enums/status_pokoju.dart';
import '../models/gosc.dart';
import '../models/pokoj.dart';
import '../models/recepcjonista.dart';
import '../models/rezerwacja.dart';
import '../models/uzytkownik.dart';

class LokalneRepozytoriumHotelu {
  LokalneRepozytoriumHotelu({
    required this.pokoje,
    required this.uzytkownicy,
    List<Rezerwacja>? rezerwacje,
  }) : rezerwacje = rezerwacje ?? [];

  factory LokalneRepozytoriumHotelu.demo() {
    return LokalneRepozytoriumHotelu(
      pokoje: [
        Pokoj(
          idPokoju: 1,
          nrPokoju: 101,
          pojemnoscPokoju: 2,
          cenaZaDobe: 250,
          statusPokoju: StatusPokoju.dostepny,
        ),
        Pokoj(
          idPokoju: 2,
          nrPokoju: 102,
          pojemnoscPokoju: 1,
          cenaZaDobe: 180,
          statusPokoju: StatusPokoju.dostepny,
        ),
        Pokoj(
          idPokoju: 3,
          nrPokoju: 201,
          pojemnoscPokoju: 3,
          cenaZaDobe: 360,
          statusPokoju: StatusPokoju.dostepny,
        ),
        Pokoj(
          idPokoju: 4,
          nrPokoju: 301,
          pojemnoscPokoju: 4,
          cenaZaDobe: 480,
          statusPokoju: StatusPokoju.dostepny,
        ),
      ],
      uzytkownicy: [
        Gosc(
          idUzytkownika: 1,
          imie: 'Jan',
          nazwisko: 'Kowalski',
          email: 'jan.kowalski@example.local',
          nrTelefonu: '123456789',
          iloscPunktowLojalnosciowych: 20,
        ),
        Gosc(
          idUzytkownika: 2,
          imie: 'Maria',
          nazwisko: 'Nowak',
          email: 'maria.nowak@example.local',
          nrTelefonu: '987654321',
          iloscPunktowLojalnosciowych: 45,
        ),
        Recepcjonista(
          idUzytkownika: 3,
          imie: 'Anna',
          nazwisko: 'Zielinska',
          email: 'anna.zielinska@example.local',
          nrTelefonu: '555666777',
          idPracownika: 100,
          rodzajZmian: 'poranna',
        ),
      ],
    );
  }

  final List<Pokoj> pokoje;
  final List<Uzytkownik> uzytkownicy;
  final List<Rezerwacja> rezerwacje;

  List<Gosc> get goscie {
    return uzytkownicy.whereType<Gosc>().toList();
  }

  List<Recepcjonista> get recepcjonisci {
    return uzytkownicy.whereType<Recepcjonista>().toList();
  }

  Pokoj znajdzPokojPoId(int idPokoju) {
    return pokoje.firstWhere(
      (pokoj) => pokoj.idPokoju == idPokoju,
      orElse: () => throw StateError('Nie znaleziono pokoju.'),
    );
  }

  Gosc znajdzGosciaPoId(int idGoscia) {
    return uzytkownicy.whereType<Gosc>().firstWhere(
      (gosc) => gosc.idUzytkownika == idGoscia,
      orElse: () => throw StateError('Nie znaleziono goscia.'),
    );
  }
}
