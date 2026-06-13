import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/models/ocena_pobytu.dart';

void main() {
  group('OcenaPobytu', () {
    test('zwraca liczbe gwiazdek', () {
      final ocena = OcenaPobytu(
        idOceny: 1,
        liczbaGwiazdek: 5,
        komentarz: 'Bardzo dobry pobyt',
        dataDodania: DateTime(2026, 6, 10),
      );

      expect(ocena.getLiczbaGwiazdek(), 5);
    });

    test('nie pozwala utworzyc oceny poza zakresem 1-5', () {
      expect(
        () => OcenaPobytu(
          idOceny: 1,
          liczbaGwiazdek: 6,
          komentarz: 'Za duzo',
          dataDodania: DateTime(2026, 6, 10),
        ),
        throwsArgumentError,
      );
    });
  });
}
