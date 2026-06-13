import '../enums/status_rezerwacji.dart';
import 'gosc.dart';
import 'ocena_pobytu.dart';
import 'platnosc.dart';
import 'pokoj.dart';

class Rezerwacja {
  Rezerwacja({
    required this.idRezerwacji,
    required this.dataPoczatkowa,
    required this.dataKoncowa,
    required this.calkowitaCena,
    required this.status,
    this.gosc,
    List<Pokoj>? pokoje,
    this.platnosc,
    this.ocenaPobytu,
    this.kodPin,
  }) : pokoje = pokoje ?? [];

  final int idRezerwacji;
  DateTime dataPoczatkowa;
  DateTime dataKoncowa;
  double calkowitaCena;
  StatusRezerwacji status;
  Gosc? gosc;
  final List<Pokoj> pokoje;
  Platnosc? platnosc;
  OcenaPobytu? ocenaPobytu;
  String? kodPin;

  void potwierdzRezerwacje() {
    status = StatusRezerwacji.potwierdzona;
  }

  void anulujRezerwacje() {
    status = StatusRezerwacji.anulowana;
  }

  bool modyfikujDaty(DateTime nDataPoczatkowa, DateTime nDataKoncowa) {
    if (!nDataKoncowa.isAfter(nDataPoczatkowa)) {
      return false;
    }

    dataPoczatkowa = nDataPoczatkowa;
    dataKoncowa = nDataKoncowa;
    return true;
  }

  int obliczDlugoscPobytu() {
    return dataKoncowa.difference(dataPoczatkowa).inDays;
  }

  bool dodajOcenePobytu(OcenaPobytu ocena) {
    ocenaPobytu = ocena;
    return true;
  }
}
