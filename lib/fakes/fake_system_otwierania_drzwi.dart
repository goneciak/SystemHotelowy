import 'dart:math';

import '../interfaces/i_system_otwierania_drzwi.dart';

class FakeSystemOtwieraniaDrzwi implements ISystemOtwieraniaDrzwi {
  FakeSystemOtwieraniaDrzwi({Random? random}) : _random = random ?? Random();

  final Map<int, String> aktywnePiny = {};
  final Random _random;

  @override
  String stworzKodPIN(int nrPokoju) {
    final kodPin = _random.nextInt(10000).toString().padLeft(4, '0');
    aktywnePiny[nrPokoju] = kodPin;
    return kodPin;
  }

  @override
  void dezaktywujKodPIN(int nrPokoju) {
    aktywnePiny.remove(nrPokoju);
  }
}
