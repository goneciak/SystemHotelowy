import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/fakes/fake_serwis_email.dart';

void main() {
  group('FakeSerwisEmail', () {
    test('zapisuje wyslane potwierdzenie rezerwacji', () {
      final serwisEmail = FakeSerwisEmail();

      serwisEmail.wyslijPotwierdzenie('jan@example.local', 1);

      expect(serwisEmail.wyslanePotwierdzenia, hasLength(1));
      expect(serwisEmail.wyslanePotwierdzenia.single.email, 'jan@example.local');
      expect(serwisEmail.wyslanePotwierdzenia.single.idRezerwacji, 1);
    });
  });
}
