import '../interfaces/i_system_platnosci.dart';

class Platnosc {
  Platnosc({
    required this.idPlatnosci,
    required this.naleznoscDoZaplaty,
    required this.dataPlatnosci,
    required this.systemPlatnosci,
    this.czyPoprawna = false,
  });

  final int idPlatnosci;
  final double naleznoscDoZaplaty;
  final DateTime dataPlatnosci;
  final ISystemPlatnosci systemPlatnosci;
  bool czyPoprawna;

  bool wykonajPlatnosc() {
    if (naleznoscDoZaplaty <= 0) {
      czyPoprawna = false;
      return false;
    }

    czyPoprawna = systemPlatnosci.przetworzPlatnosc(naleznoscDoZaplaty);
    return czyPoprawna;
  }
}
