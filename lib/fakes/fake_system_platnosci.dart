import '../interfaces/i_system_platnosci.dart';

class FakeSystemPlatnosci implements ISystemPlatnosci {
  FakeSystemPlatnosci({this.czyPlatnoscPoprawna = true});

  final bool czyPlatnoscPoprawna;
  final List<double> przetworzoneKwoty = [];

  @override
  bool przetworzPlatnosc(double calkowitaKwota) {
    przetworzoneKwoty.add(calkowitaKwota);
    return czyPlatnoscPoprawna;
  }
}
