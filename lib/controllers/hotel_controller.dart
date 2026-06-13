import '../enums/status_pokoju.dart';
import '../data/lokalne_repozytorium_hotelu.dart';
import '../enums/status_rezerwacji.dart';
import '../fakes/fake_serwis_email.dart';
import '../fakes/fake_system_otwierania_drzwi.dart';
import '../fakes/fake_system_platnosci.dart';
import '../models/ocena_pobytu.dart';
import '../models/platnosc.dart';
import '../models/pokoj.dart';
import '../models/rezerwacja.dart';
import '../services/serwis_rezerwacji.dart';
import '../services/serwis_zameldowania.dart';

class HotelController {
  HotelController({
    required this.repozytorium,
    required this.serwisRezerwacji,
    required this.serwisZameldowania,
    required this.serwisEmail,
    required this.systemPlatnosci,
    required this.systemOtwieraniaDrzwi,
  });

  factory HotelController.demo({
    bool czyPlatnoscPoprawna = true,
    DateTime? dzisiejszaData,
  }) {
    final repozytorium = LokalneRepozytoriumHotelu.demo();
    final serwisEmail = FakeSerwisEmail();
    final systemOtwieraniaDrzwi = FakeSystemOtwieraniaDrzwi();
    final dataWalidacji = dzisiejszaData ?? DateTime.now();

    return HotelController(
      repozytorium: repozytorium,
      serwisRezerwacji: SerwisRezerwacji(
        serwisEmail: serwisEmail,
        pokoje: repozytorium.pokoje,
        goscie: repozytorium.goscie,
        dzisiejszaData: dataWalidacji,
      ),
      serwisZameldowania: SerwisZameldowania(
        systemOtwieraniaDrzwi: systemOtwieraniaDrzwi,
        pokoje: repozytorium.pokoje,
      ),
      serwisEmail: serwisEmail,
      systemPlatnosci: FakeSystemPlatnosci(
        czyPlatnoscPoprawna: czyPlatnoscPoprawna,
      ),
      systemOtwieraniaDrzwi: systemOtwieraniaDrzwi,
    );
  }

  final LokalneRepozytoriumHotelu repozytorium;
  final SerwisRezerwacji serwisRezerwacji;
  final SerwisZameldowania serwisZameldowania;
  final FakeSerwisEmail serwisEmail;
  final FakeSystemPlatnosci systemPlatnosci;
  final FakeSystemOtwieraniaDrzwi systemOtwieraniaDrzwi;
  int _nastepneIdPlatnosci = 1;
  int _nastepneIdOceny = 1;

  List<Rezerwacja> get rezerwacje {
    return repozytorium.rezerwacje;
  }

  Rezerwacja utworzRezerwacje({
    required int idGoscia,
    required int idPokoju,
    required DateTime dataPoczatkowa,
    required DateTime dataKoncowa,
  }) {
    final rezerwacja = serwisRezerwacji.stworzRezerwacje(
      idGoscia: idGoscia,
      idPokoju: idPokoju,
      dataPoczatkowa: dataPoczatkowa,
      dataKoncowa: dataKoncowa,
    );

    repozytorium.rezerwacje.add(rezerwacja);
    rezerwacja.kodPin = systemOtwieraniaDrzwi.stworzKodPIN(
      rezerwacja.pokoje.single.nrPokoju,
    );
    return rezerwacja;
  }

  List<Pokoj> znajdzDostepnePokoje({
    required DateTime dataPoczatkowa,
    required DateTime dataKoncowa,
    required int liczbaGosci,
  }) {
    return serwisRezerwacji.znajdzDostepnePokoje(
      dataPoczatkowa: dataPoczatkowa,
      dataKoncowa: dataKoncowa,
      liczbaGosci: liczbaGosci,
    );
  }

  void zmienStatusPokoju({
    required int idPokoju,
    required StatusPokoju nowyStatus,
  }) {
    repozytorium.znajdzPokojPoId(idPokoju).zmienStatus(nowyStatus);
  }

  bool anulujRezerwacje({
    required int idRezerwacji,
    required String powod,
  }) {
    return serwisRezerwacji.anulujRezerwacje(
      idRezerwacji: idRezerwacji,
      powod: powod,
    );
  }

  bool modyfikujDatyRezerwacji({
    required int idRezerwacji,
    required DateTime nowaDataPoczatkowa,
    required DateTime nowaDataKoncowa,
  }) {
    return serwisRezerwacji.modyfikujDatyRezerwacji(
      idRezerwacji: idRezerwacji,
      nowaDataPoczatkowa: nowaDataPoczatkowa,
      nowaDataKoncowa: nowaDataKoncowa,
    );
  }

  String zamelduj({required int idRezerwacji}) {
    return serwisZameldowania.przetworzZameldowanie(
      idRezerwacji: idRezerwacji,
    );
  }

  bool wymelduj({required int idRezerwacji}) {
    return serwisZameldowania.przetworzWymeldowanie(
      idRezerwacji: idRezerwacji,
    );
  }

  Platnosc wykonajPlatnosc({required int idRezerwacji}) {
    final rezerwacja = _znajdzRezerwacje(idRezerwacji);
    final isAlreadyPaid = rezerwacja.platnosc?.czyPoprawna == true;
    if (isAlreadyPaid) {
      return rezerwacja.platnosc!;
    }

    final platnosc = Platnosc(
      idPlatnosci: _nastepneIdPlatnosci++,
      naleznoscDoZaplaty: rezerwacja.calkowitaCena,
      dataPlatnosci: DateTime.now(),
      systemPlatnosci: systemPlatnosci,
    )..wykonajPlatnosc();

    rezerwacja.platnosc = platnosc;
    return platnosc;
  }

  bool dodajOcenePobytu({
    required int idRezerwacji,
    required int liczbaGwiazdek,
    required String komentarz,
    required DateTime dataDodania,
  }) {
    final rezerwacja = _znajdzRezerwacje(idRezerwacji);
    if (rezerwacja.status != StatusRezerwacji.zakonczona) {
      return false;
    }

    final ocena = OcenaPobytu(
      idOceny: _nastepneIdOceny++,
      liczbaGwiazdek: liczbaGwiazdek,
      komentarz: komentarz,
      dataDodania: dataDodania,
    );

    return rezerwacja.dodajOcenePobytu(ocena);
  }

  Rezerwacja _znajdzRezerwacje(int idRezerwacji) {
    return repozytorium.rezerwacje.firstWhere(
      (rezerwacja) => rezerwacja.idRezerwacji == idRezerwacji,
      orElse: () => throw StateError('Nie znaleziono rezerwacji.'),
    );
  }
}
