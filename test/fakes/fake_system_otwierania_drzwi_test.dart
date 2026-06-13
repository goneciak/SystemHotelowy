import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/fakes/fake_system_otwierania_drzwi.dart';

void main() {
  group('FakeSystemOtwieraniaDrzwi', () {
    test('tworzy kod PIN dla numeru pokoju', () {
      final system = FakeSystemOtwieraniaDrzwi();

      final kodPin = system.stworzKodPIN(101);

      expect(kodPin, 'PIN-101');
      expect(system.aktywnePiny[101], 'PIN-101');
    });

    test('dezaktywuje kod PIN dla numeru pokoju', () {
      final system = FakeSystemOtwieraniaDrzwi();
      system.stworzKodPIN(101);

      system.dezaktywujKodPIN(101);

      expect(system.aktywnePiny.containsKey(101), isFalse);
    });
  });
}
