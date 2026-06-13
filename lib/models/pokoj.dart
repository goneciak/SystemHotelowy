import '../enums/status_pokoju.dart';
import '../enums/status_rezerwacji.dart';
import 'rezerwacja.dart';

class Pokoj {
  Pokoj({
    required this.idPokoju,
    required this.nrPokoju,
    required this.pojemnoscPokoju,
    required this.cenaZaDobe,
    required this.statusPokoju,
    List<Rezerwacja>? rezerwacje,
  }) : rezerwacje = rezerwacje ?? [];

  final int idPokoju;
  final int nrPokoju;
  final int pojemnoscPokoju;
  double cenaZaDobe;
  StatusPokoju statusPokoju;
  final List<Rezerwacja> rezerwacje;

  double obliczKoszt(int iloscDni) {
    return cenaZaDobe * iloscDni;
  }

  void zmienStatus(StatusPokoju nowyStatus) {
    statusPokoju = nowyStatus;
  }

  bool czyDostepny(DateTime dataPoczatkowa, DateTime dataKoncowa) {
    if (statusPokoju == StatusPokoju.wylaczony ||
        statusPokoju == StatusPokoju.czyszczenie ||
        !dataKoncowa.isAfter(dataPoczatkowa)) {
      return false;
    }

    return rezerwacje.where(_blokujeDostepnosc).every((rezerwacja) {
      return !_terminySiePokrywaja(
        dataPoczatkowa,
        dataKoncowa,
        rezerwacja.dataPoczatkowa,
        rezerwacja.dataKoncowa,
      );
    });
  }

  bool _blokujeDostepnosc(Rezerwacja rezerwacja) {
    return rezerwacja.status != StatusRezerwacji.anulowana;
  }

  bool _terminySiePokrywaja(
    DateTime poczatekA,
    DateTime koniecA,
    DateTime poczatekB,
    DateTime koniecB,
  ) {
    return poczatekA.isBefore(koniecB) && koniecA.isAfter(poczatekB);
  }
}
