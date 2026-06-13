import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/data/lokalne_repozytorium_hotelu.dart';
import 'package:hotel/enums/status_pokoju.dart';
import 'package:hotel/models/gosc.dart';
import 'package:hotel/models/recepcjonista.dart';

void main() {
  group('LokalneRepozytoriumHotelu', () {
    test('tworzy repozytorium z danymi demonstracyjnymi', () {
      final repozytorium = LokalneRepozytoriumHotelu.demo();

      expect(repozytorium.pokoje, hasLength(4));
      expect(repozytorium.uzytkownicy.whereType<Gosc>(), hasLength(2));
      expect(repozytorium.uzytkownicy.whereType<Recepcjonista>(), hasLength(1));
      expect(
        repozytorium.pokoje.every(
          (pokoj) => pokoj.statusPokoju == StatusPokoju.dostepny,
        ),
        isTrue,
      );
    });

    test('znajduje pokoj po id', () {
      final repozytorium = LokalneRepozytoriumHotelu.demo();

      final pokoj = repozytorium.znajdzPokojPoId(1);

      expect(pokoj.nrPokoju, 101);
    });

    test('znajduje goscia po id', () {
      final repozytorium = LokalneRepozytoriumHotelu.demo();

      final gosc = repozytorium.znajdzGosciaPoId(1);

      expect(gosc.email, 'jan.kowalski@example.local');
    });
  });
}
