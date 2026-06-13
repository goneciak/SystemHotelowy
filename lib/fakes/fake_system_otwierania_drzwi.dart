import '../interfaces/i_system_otwierania_drzwi.dart';

class FakeSystemOtwieraniaDrzwi implements ISystemOtwieraniaDrzwi {
  final Map<int, String> aktywnePiny = {};

  @override
  String stworzKodPIN(int nrPokoju) {
    final kodPin = 'PIN-$nrPokoju';
    aktywnePiny[nrPokoju] = kodPin;
    return kodPin;
  }

  @override
  void dezaktywujKodPIN(int nrPokoju) {
    aktywnePiny.remove(nrPokoju);
  }
}
